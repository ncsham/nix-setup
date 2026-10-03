"""awsx-okta: AWS credentials from Okta Identity Engine tiles via Okta Verify push.

usage:
  awsx-okta saml <tile-url>                           base64 SAMLResponse on stdout
  awsx-okta roles < saml                              per account: "Account: name (id)", role ARNs, blank line
  awsx-okta sts <profile> <role-arn> <seconds> < saml assume the role, write <profile> credentials

The Okta session cookie is kept in $AWSX_DIR/okta-cookies.txt, so `saml` for any
tile reuses it and needs no push until the Okta session ends.
`sts` exits with status 3 when the role does not allow that session length.
Env: AWSX_OKTA_USER (Okta username), AWSX_DIR, AWS_SHARED_CREDENTIALS_FILE.
"""
import base64
import datetime
import html
import http.cookiejar
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

ION = "application/ion+json; okta-version=1.0.0"
USER_AGENT = "Mozilla/5.0 (Macintosh) awsx-okta"
KEYCHAIN_SERVICE = "awsx-okta"
PUSH_TIMEOUT = 180
ROLE_ATTRIBUTE = "https://aws.amazon.com/SAML/Attributes/Role"
SIGNIN_URL = "https://signin.aws.amazon.com/saml"
STS_URL = "https://sts.amazonaws.com/"
EXIT_DURATION = 3


class AwsxError(Exception):
    pass


class DurationTooLong(AwsxError):
    pass


def say(message):
    print(message, file=sys.stderr, flush=True)


# ── Okta pages ────────────────────────────────────────────────────────────────

def state_token(page):
    m = re.search(r'"stateToken"\s*:\s*"([^"]+)"', page)
    if not m:
        return None
    return re.sub(r"\\x([0-9A-Fa-f]{2})", lambda h: chr(int(h.group(1), 16)), m.group(1))


def saml_from_html(page):
    for tag in re.findall(r"<input\b[^>]*>", page, re.IGNORECASE):
        if re.search(r'\bname="SAMLResponse"', tag):
            m = re.search(r'\bvalue="([^"]*)"', tag)
            if m:
                return html.unescape(m.group(1))
    return None


# ── Okta Identity Engine (IDX) sign-in ────────────────────────────────────────

def _remediations(doc):
    return {r.get("name"): r for r in doc.get("remediation", {}).get("value", [])}


def _fields(remediation):
    return {f.get("name"): f for f in remediation.get("value", [])}


def _errors(doc):
    return [m.get("message", "") for m in doc.get("messages", {}).get("value", [])
            if m.get("class") == "ERROR"]


def _describe(doc):
    steps = [f"{name}({', '.join(n for n in _fields(r) if n != 'stateHandle')})"
             for name, r in _remediations(doc).items()]
    return ", ".join(steps) or "none"


def _correct_answer(doc):
    for key in ("currentAuthenticator", "currentAuthenticatorEnrollment"):
        data = doc.get(key, {}).get("value", {}).get("contextualData", {})
        if data.get("correctAnswer"):
            return str(data["correctAnswer"])
    return None


def _is_password_challenge(doc):
    current = doc.get("currentAuthenticatorEnrollment", {}).get("value", {})
    return current.get("type") == "password" or current.get("key") == "okta_password"


def _push_authenticator_id(remediation):
    """Id of the authenticator offering push, from a list of authenticators or a single form."""
    field = _fields(remediation).get("authenticator", {})
    forms = [o.get("value", {}).get("form", {}) for o in field.get("options", [])] + [field.get("form", {})]
    for form in forms:
        form = {f.get("name"): f for f in form.get("value", [])}
        method = form.get("methodType", {})
        methods = [o.get("value") for o in method.get("options", [])] or [method.get("value")]
        if "push" in methods and form.get("id", {}).get("value"):
            return form["id"]["value"]
    return None


def okta_saml(client, tile_url, username, get_password, sleep=time.sleep, clock=time.monotonic):
    """SAMLResponse for a tile: reuse the Okta session, else sign in with password + push."""
    final_url, page = client.get(tile_url)
    saml = saml_from_html(page)
    if saml:
        return saml
    token = state_token(page)
    if not token:
        raise AwsxError(f"no Okta sign-in form at {final_url.split('?')[0]}")
    host = "https://" + urllib.parse.urlsplit(final_url).netloc
    doc = client.post_ion(f"{host}/idp/idx/introspect", {"stateToken": token})

    sent_password = False
    waiting_since = None
    shown_answer = None
    for _ in range(500):
        errors = _errors(doc)
        if errors:
            hint = " (if your Okta password changed, run: awsx password)" if sent_password else ""
            raise AwsxError("; ".join(errors) + hint)
        if "success" in doc:
            _, page = client.get(doc["success"]["href"])
            saml = saml_from_html(page) or saml_from_html(client.get(tile_url)[1])
            if not saml:
                raise AwsxError("signed in to Okta, but the tile returned no SAML response")
            return saml

        steps = _remediations(doc)
        handle = doc.get("stateHandle")
        sent_password = False
        if "identify" in steps:
            step = steps["identify"]
            fields = _fields(step)
            body = {"identifier": username}
            if "credentials" in fields:
                body["credentials"] = {"passcode": get_password()}
                sent_password = True
            if "rememberMe" in fields:
                body["rememberMe"] = True
        elif "challenge-authenticator" in steps and _is_password_challenge(doc):
            step = steps["challenge-authenticator"]
            body = {"credentials": {"passcode": get_password()}}
            sent_password = True
        elif "challenge-poll" in steps:
            step = steps["challenge-poll"]
            if waiting_since is None:
                waiting_since = clock()
                say("Okta Verify push sent; approve it on your phone ...")
            elif clock() - waiting_since > PUSH_TIMEOUT:
                raise AwsxError("Okta Verify push was not approved in time")
            answer = _correct_answer(doc)
            if answer and answer != shown_answer:
                say(f"Okta Verify number challenge: tap {answer}")
                shown_answer = answer
            sleep(step.get("refresh", 4000) / 1000)
            body = {}
        elif "select-authenticator-authenticate" in steps or "authenticator-verification-data" in steps:
            step = steps.get("authenticator-verification-data") or steps["select-authenticator-authenticate"]
            authenticator = _push_authenticator_id(step)
            if not authenticator:
                raise AwsxError("Okta did not offer Okta Verify push; offered: " + _describe(doc))
            body = {"authenticator": {"id": authenticator, "methodType": "push"}}
        elif "skip" in steps:
            step = steps["skip"]
            body = {}
        else:
            raise AwsxError("unsupported Okta sign-in step: " + _describe(doc))
        body["stateHandle"] = handle
        doc = client.post_ion(step["href"], body)
    raise AwsxError("Okta sign-in did not finish")


class OktaHttp:
    """urllib client with a persistent cookie jar (the Okta session)."""

    def __init__(self, cookie_file):
        self.cookie_file = cookie_file
        self.jar = http.cookiejar.MozillaCookieJar(cookie_file)
        if os.path.exists(cookie_file):
            try:
                self.jar.load(ignore_discard=True)
            except (http.cookiejar.LoadError, OSError):
                pass
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))
        self.opener.addheaders = [("User-Agent", USER_AGENT)]

    def get(self, url):
        request = urllib.request.Request(url, headers={"Accept": "text/html"})
        with self.opener.open(request, timeout=30) as r:
            return r.geturl(), r.read().decode("utf-8", "replace")

    def post_ion(self, url, body):
        request = urllib.request.Request(url, data=json.dumps(body).encode(), method="POST",
                                         headers={"Content-Type": ION, "Accept": ION})
        try:
            with self.opener.open(request, timeout=30) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            try:
                return json.loads(e.read())
            except ValueError:
                raise AwsxError(f"Okta returned HTTP {e.code} for {url.split('?')[0]}") from None

    def save(self):
        os.makedirs(os.path.dirname(self.cookie_file), mode=0o700, exist_ok=True)
        os.close(os.open(self.cookie_file, os.O_CREAT | os.O_WRONLY, 0o600))
        self.jar.save(ignore_discard=True)


# ── AWS ───────────────────────────────────────────────────────────────────────

def _assertion_root(saml_b64):
    try:
        return ET.fromstring(base64.b64decode(saml_b64))
    except (ValueError, ET.ParseError) as e:
        raise AwsxError(f"not a SAML response: {e}") from None


def roles_from_assertion(saml_b64):
    """[(role_arn, principal_arn)] from the assertion's AWS Role attribute."""
    pairs = []
    for attribute in _assertion_root(saml_b64).iter():
        if not (attribute.tag.endswith("}Attribute") and attribute.get("Name") == ROLE_ATTRIBUTE):
            continue
        for value in attribute:
            parts = [p.strip() for p in (value.text or "").split(",")]
            role = next((p for p in parts if ":role/" in p), None)
            principal = next((p for p in parts if ":saml-provider/" in p), None)
            if role and principal:
                pairs.append((role, principal))
    return pairs


def signin_account_labels(page):
    """{account_id: 'Account: name (id)'} from the AWS SAML sign-in page."""
    labels = {}
    for text in re.findall(r'class="saml-account-name"[^>]*>([^<]*)<', page):
        text = html.unescape(text).strip()
        m = re.search(r"(\d{12})\)?$", text)
        if m:
            labels[m.group(1)] = text
    return labels


def format_roles(pairs, labels):
    """Per account: 'Account: name (id)', its role ARNs, a blank line."""
    by_account = {}
    for role, _ in pairs:
        roles = by_account.setdefault(role.split(":")[4], [])
        if role not in roles:
            roles.append(role)
    lines = []
    for account, roles in by_account.items():
        lines += [labels.get(account, f"Account: {account}"), *roles, ""]
    return "".join(line + "\n" for line in lines)


def _post_form(url, data):
    request = urllib.request.Request(url, data=data, method="POST", headers={
        "Content-Type": "application/x-www-form-urlencoded", "User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def account_labels(saml_b64):
    destination = _assertion_root(saml_b64).get("Destination") or SIGNIN_URL
    status, body = _post_form(destination, urllib.parse.urlencode({"SAMLResponse": saml_b64}).encode())
    if status != 200:
        raise AwsxError(f"AWS sign-in page returned HTTP {status}")
    return signin_account_labels(body.decode("utf-8", "replace"))


def _xml_text(root, name):
    element = next((e for e in root.iter() if e.tag.rsplit("}", 1)[-1] == name), None)
    return element.text if element is not None else None


def parse_sts(status, body):
    try:
        root = ET.fromstring(body)
    except ET.ParseError:
        raise AwsxError(f"STS returned HTTP {status}") from None
    if status != 200:
        code, message = _xml_text(root, "Code"), _xml_text(root, "Message") or ""
        if "DurationSeconds" in message:
            raise DurationTooLong(message)
        if not code:
            raise AwsxError(f"STS returned HTTP {status}")
        raise AwsxError(f"STS {code}: {message}")
    creds = {k: _xml_text(root, k) for k in ("AccessKeyId", "SecretAccessKey", "SessionToken", "Expiration", "Arn")}
    if not all(creds.values()):
        raise AwsxError(f"STS returned HTTP {status} without credentials")
    return creds


def assume_role(role_arn, principal_arn, saml_b64, seconds):
    data = urllib.parse.urlencode({
        "Action": "AssumeRoleWithSAML", "Version": "2011-06-15", "RoleArn": role_arn,
        "PrincipalArn": principal_arn, "SAMLAssertion": saml_b64, "DurationSeconds": str(seconds),
    }).encode()
    return parse_sts(*_post_form(STS_URL, data))


def write_credentials(path, profile, creds):
    """Replace only [profile] in the shared credentials file; everything else is kept verbatim."""
    expires = datetime.datetime.fromisoformat(creds["Expiration"].replace("Z", "+00:00")).astimezone()
    section = [
        f"[{profile}]",
        f"aws_access_key_id        = {creds['AccessKeyId']}",
        f"aws_secret_access_key    = {creds['SecretAccessKey']}",
        f"aws_session_token        = {creds['SessionToken']}",
        f"aws_security_token       = {creds['SessionToken']}",
        f"x_principal_arn          = {creds['Arn']}",
        f"x_security_token_expires = {expires.isoformat(timespec='seconds')}",
    ]
    try:
        with open(path) as f:
            lines = f.read().splitlines()
    except FileNotFoundError:
        lines = []
    kept, skipping = [], False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            skipping = stripped[1:-1].strip() == profile
        if not skipping:
            kept.append(line)
    while kept and not kept[-1].strip():
        kept.pop()
    text = "".join(line + "\n" for line in kept + ([""] if kept else []) + section)
    directory = os.path.dirname(path) or "."
    os.makedirs(directory, mode=0o700, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=directory, prefix=".credentials.")
    with os.fdopen(fd, "w") as f:
        f.write(text)
    os.replace(tmp, path)


# ── CLI ───────────────────────────────────────────────────────────────────────

def _env_path(name, default):
    return os.path.expanduser(os.environ.get(name) or default)


def _okta_user():
    user = os.environ.get("AWSX_OKTA_USER")
    if not user:
        raise AwsxError("AWSX_OKTA_USER is not set")
    return user


def keychain_password():
    result = subprocess.run(["security", "find-generic-password", "-s", KEYCHAIN_SERVICE,
                             "-a", _okta_user(), "-w"], capture_output=True, text=True)
    if result.returncode != 0:
        raise AwsxError("no Okta password in the Keychain; run: awsx password")
    return result.stdout.rstrip("\n")


def main(argv):
    command, args = (argv[1], argv[2:]) if len(argv) > 1 else ("", [])
    try:
        if command == "saml" and len(args) == 1:
            client = OktaHttp(os.path.join(_env_path("AWSX_DIR", "~/.aws/awsx"), "okta-cookies.txt"))
            try:
                print(okta_saml(client, args[0], _okta_user(), keychain_password))
            finally:
                client.save()
        elif command == "roles" and not args:
            saml = sys.stdin.read().strip()
            try:
                labels = account_labels(saml)
            except (AwsxError, urllib.error.URLError) as e:
                say(f"awsx-okta: could not read account names from AWS ({e}); using account ids")
                labels = {}
            sys.stdout.write(format_roles(roles_from_assertion(saml), labels))
        elif command == "sts" and len(args) == 3:
            profile, role_arn, seconds = args
            saml = sys.stdin.read().strip()
            principal = dict(roles_from_assertion(saml)).get(role_arn)
            if not principal:
                raise AwsxError(f"{role_arn} is not in the SAML response")
            creds = assume_role(role_arn, principal, saml, int(seconds))
            write_credentials(_env_path("AWS_SHARED_CREDENTIALS_FILE", "~/.aws/credentials"), profile, creds)
        else:
            say(__doc__.strip())
            return 2
    except DurationTooLong:
        return EXIT_DURATION
    except AwsxError as e:
        say(f"awsx-okta: {e}")
        return 1
    except urllib.error.URLError as e:
        say(f"awsx-okta: network error: {e.reason}")
        return 1
    except KeyboardInterrupt:
        return 130
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
