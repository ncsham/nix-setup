# awsx: one AWS CLI profile per account behind Okta SAML tiles, using awsx-okta.
# Built by home/aws.nix, which sets AWSX_TILES ("name=url ...") and AWSX_OKTA_USER.

AWSX_DIR="${AWSX_DIR:-$HOME/.aws/awsx}"
INDEX="$AWSX_DIR/accounts.tsv"
CREDS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
KEYCHAIN_SERVICE="awsx-okta"
MAX_DURATION=43200
FALLBACK_DURATION=3600
# awsx-okta sts exit status when the role does not allow the requested session length.
EXIT_DURATION=3
# Credentials with less than this many seconds left are refreshed.
MIN_LEFT=300
TAB=$'\t'

# One SAML assertion per tile per run (saml.<tile>), so each tile needs at most one push.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

die() {
  printf 'awsx: %s\n' "$*" >&2
  exit 1
}
say() { printf '%s\n' "$*" >&2; }

usage() {
  cat >&2 <<'EOF'
usage: awsx <command>
  login [-f] [tile...]    discover accounts in Okta tiles (default: all) and refresh them
  ls                      list profiles and credential status
  refresh [-f] <profile>  refresh one profile if expired (-f: always)
  pick [query]            choose a profile (fzf), refresh it if needed, print its name
  password                store or update the Okta password in the Keychain
EOF
}

tile_names() {
  local -a entries
  local entry
  read -r -a entries <<<"${AWSX_TILES:?}"
  for entry in "${entries[@]}"; do printf '%s\n' "${entry%%=*}"; done
}

tile_url() {
  local -a entries
  local entry
  read -r -a entries <<<"${AWSX_TILES:?}"
  for entry in "${entries[@]}"; do
    if [[ "${entry%%=*}" == "$1" ]]; then
      printf '%s\n' "${entry#*=}"
      return 0
    fi
  done
  return 1
}

tile_known() { tile_url "$1" >/dev/null; }

# POSIX awk helpers: RFC3339 timestamp (2026-10-03T16:31:08+05:30, ...Z) -> unix seconds.
AWK_TIME='
function days_from_civil(y, m, d,    era, yoe, doy, doe) {
  y -= (m <= 2)
  era = int(y / 400)
  yoe = y - era * 400
  doy = int((153 * (m > 2 ? m - 3 : m + 9) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return era * 146097 + doe - 719468
}
function to_epoch(ts,    s, off, o) {
  s = days_from_civil(substr(ts, 1, 4) + 0, substr(ts, 6, 2) + 0, substr(ts, 9, 2) + 0) * 86400
  s += substr(ts, 12, 2) * 3600 + substr(ts, 15, 2) * 60 + substr(ts, 18, 2)
  off = substr(ts, 20)
  sub(/^\.[0-9]+/, "", off)
  if (off ~ /^[+-][0-9][0-9]:[0-9][0-9]$/) {
    o = substr(off, 2, 2) * 3600 + substr(off, 5, 2) * 60
    s += (substr(off, 1, 1) == "+") ? -o : o
  }
  return s
}
'

# stdin: `awsx-okta roles` output for <tile>. stdout: index rows for that tile.
parse_roles() {
  local tile="$1"
  awk -v tile="$tile" -v index_file="$INDEX" -v def="$MAX_DURATION" '
    BEGIN {
      FS = OFS = "\t"
      while ((getline line < index_file) > 0) {
        split(line, f, "\t")
        if (f[2] == tile) dur[f[4]] = f[5]
        else taken[f[1]] = 1
      }
    }
    { sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, "") }
    /^Account: / {
      name = substr($0, 10)
      sub(/ *\([0-9]+\)$/, "", name)
      if (name ~ /^[0-9]+$/) name = ""
      next
    }
    /^arn:aws[a-z-]*:iam::[0-9]+:role\// {
      n++
      arn[n] = $0
      split($0, parts, ":")
      id[n] = parts[5]
      role[n] = $0
      sub(/.*\//, "", role[n])
      acct[n] = (name == "") ? id[n] : name
      roles_in[id[n]]++
    }
    END {
      for (i = 1; i <= n; i++) {
        prof = acct[i]
        if (roles_in[id[i]] > 1) prof = prof "--" role[i]
        if (prof in taken) prof = prof "--" tile
        print prof, tile, id[i], arn[i], (arn[i] in dur) ? dur[arn[i]] : def
      }
    }
  '
}

# Index rows plus credential state:
# profile, tile, account_id, role_arn, duration_seconds, seconds_left (-1 = no creds), expires.
status_tsv() {
  [[ -f "$INDEX" ]] || return 0
  awk -v creds="$CREDS_FILE" -v now="$(date +%s)" "$AWK_TIME"'
    BEGIN {
      FS = OFS = "\t"
      while ((getline line < creds) > 0) {
        if (line ~ /^[ \t]*\[/) {
          section = line
          gsub(/^[ \t]*\[|\][ \t]*$/, "", section)
        } else if (line ~ /^[ \t]*x_security_token_expires[ \t]*=/) {
          value = line
          sub(/^[^=]*=[ \t]*/, "", value)
          sub(/[ \t]*$/, "", value)
          expires[section] = value
        }
      }
    }
    {
      left = -1
      ts = ""
      if ($1 in expires) {
        ts = expires[$1]
        left = to_epoch(ts) - now
        if (left < 0) left = 0
      }
      print $1, $2, $3, $4, $5, left, ts
    }
  ' "$INDEX"
}

profile_row() { status_tsv | awk -F '\t' -v p="$1" '$1 == p'; }

replace_tile_rows() {
  local tile="$1" rows="$2"
  { awk -F '\t' -v t="$tile" '$2 != t' "$INDEX"; cat "$rows"; } >"$INDEX.tmp"
  mv "$INDEX.tmp" "$INDEX"
}

prune_unconfigured_tiles() {
  local tiles
  tiles=" $(tile_names | tr '\n' ' ')"
  awk -F '\t' -v tiles="$tiles" 'index(tiles, " " $2 " ")' "$INDEX" >"$INDEX.tmp"
  mv "$INDEX.tmp" "$INDEX"
}

set_duration() {
  awk -F '\t' -v OFS='\t' -v p="$1" -v d="$2" '$1 == p { $5 = d } { print }' "$INDEX" >"$INDEX.tmp"
  mv "$INDEX.tmp" "$INDEX"
}

# fetch_saml <tile>: Okta auth for the tile (a push only if the Okta session has ended), once per run.
fetch_saml() {
  local saml="$WORK/saml.$1" url rc=0
  [[ -s "$saml" ]] && return 0
  url="$(tile_url "$1")"
  awsx-okta saml "$url" >"$saml.tmp" || rc=$?
  if ((rc != 0)); then
    rm -f "$saml.tmp"
    return "$rc"
  fi
  mv "$saml.tmp" "$saml"
}

# login_role <profile> <tile> <role_arn> <duration>: always fetches new credentials.
login_role() {
  local profile="$1" tile="$2" arn="$3" duration="$4" saml="$WORK/saml.$2" rc=0
  fetch_saml "$tile" || rc=$?
  if ((rc == 0)); then
    awsx-okta sts "$profile" "$arn" "$duration" <"$saml" || rc=$?
  fi

  if ((rc == EXIT_DURATION && duration > FALLBACK_DURATION)); then
    say "$profile: role does not allow ${duration}s sessions; retrying with ${FALLBACK_DURATION}s"
    set_duration "$profile" "$FALLBACK_DURATION"
    rc=0
    awsx-okta sts "$profile" "$arn" "$FALLBACK_DURATION" <"$saml" || rc=$?
  fi

  if ((rc != 0)); then
    ((rc == EXIT_DURATION)) && say "$profile: role refused a ${FALLBACK_DURATION}s session"
    say "✗ $profile"
    return "$rc"
  fi
  local ts
  ts="$(profile_row "$profile" | cut -f7)"
  say "✓ $profile  valid until ${ts:11:5}"
}

cmd_refresh() {
  local force=0
  if [[ "${1:-}" == "-f" ]]; then
    force=1
    shift
  fi
  local profile="${1:?usage: awsx refresh [-f] <profile>}"
  local row tile arn duration left
  row="$(profile_row "$profile")"
  [[ -n "$row" ]] || die "unknown profile '$profile'; run awslogin"
  IFS="$TAB" read -r _ tile _ arn duration left _ <<<"$row"
  ((force == 0 && left > MIN_LEFT)) && return 0
  tile_known "$tile" || die "tile '$tile' is no longer configured; run awslogin"
  login_role "$profile" "$tile" "$arn" "$duration"
}

# discover_tile <tile>: Okta auth for the tile, then rewrite its index rows from the SAML roles.
discover_tile() {
  local tile="$1" out="$WORK/roles.out" rows="$WORK/rows.tsv"
  fetch_saml "$tile" || return
  awsx-okta roles <"$WORK/saml.$tile" >"$out" || return
  parse_roles "$tile" <"$out" >"$rows"
  if [[ ! -s "$rows" ]]; then
    say "no AWS roles found in tile '$tile'"
    return 1
  fi
  replace_tile_rows "$tile" "$rows"
}

cmd_login() {
  local force=0
  if [[ "${1:-}" == "-f" ]]; then
    force=1
    shift
  fi
  local -a tiles=() failed=()
  if (($#)); then
    tiles=("$@")
  else
    mapfile -t tiles < <(tile_names)
  fi
  local tile names
  names="$(tile_names | tr '\n' ' ')"
  for tile in "${tiles[@]}"; do
    tile_known "$tile" || die "unknown tile '$tile' (configured: ${names% })"
  done

  mkdir -p "$AWSX_DIR"
  touch "$INDEX"
  (($#)) || prune_unconfigured_tiles

  local profile arn duration left ts
  for tile in "${tiles[@]}"; do
    say "── $tile"
    if ! discover_tile "$tile"; then
      failed+=("tile:$tile")
      continue
    fi
    while IFS="$TAB" read -r profile _ _ arn duration left ts; do
      if ((force == 0 && left > MIN_LEFT)); then
        say "✓ $profile  valid until ${ts:11:5}"
      elif ! login_role "$profile" "$tile" "$arn" "$duration"; then
        failed+=("$profile")
      fi
    done < <(status_tsv | awk -F '\t' -v t="$tile" '$2 == t')
  done

  say ""
  if ((${#failed[@]})); then
    say "failed: ${failed[*]}"
    return 1
  fi
  say "done. switch with: awsp"
}

cmd_ls() {
  local color=0
  if [[ "${1:-}" == "--color" ]] || [[ -t 1 ]]; then color=1; fi
  [[ -s "$INDEX" ]] || die "no profiles yet; run awslogin"
  status_tsv | sort -t "$TAB" -k1,1 | awk -v color="$color" '
    BEGIN { FS = "\t"; pw = length("PROFILE"); tw = length("TILE") }
    {
      n++
      p[n] = $1; t[n] = $2; a[n] = $3; left[n] = $6
      if (length($1) > pw) pw = length($1)
      if (length($2) > tw) tw = length($2)
    }
    END {
      if (color) { green = "\033[32m"; red = "\033[31m"; yellow = "\033[33m"; reset = "\033[0m" }
      fmt = "%-" pw "s  %-12s  %-" tw "s  %s\n"
      printf fmt, "PROFILE", "ACCOUNT", "TILE", "STATUS"
      for (i = 1; i <= n; i++) {
        if (left[i] < 0) st = yellow "missing" reset
        else if (left[i] == 0) st = red "expired" reset
        else st = green sprintf("valid %dh%02dm", int(left[i] / 3600), int((left[i] % 3600) / 60)) reset
        printf fmt, p[i], a[i], t[i], st
      }
    }
  '
}

fzf_pick() {
  cmd_ls --color |
    fzf --ansi --header-lines=1 --query "$1" --select-1 --exit-0 \
      --prompt 'aws profile> ' --header "current: ${AWS_PROFILE:-none}" |
    awk '{ print $1 }'
}

cmd_pick() {
  local query="${1:-}" profile="" rc=0
  [[ -s "$INDEX" ]] || die "no profiles yet; run awslogin"
  if [[ -n "$query" ]] && awk -F '\t' -v p="$query" '$1 == p { found = 1 } END { exit !found }' "$INDEX"; then
    profile="$query"
  else
    profile="$(fzf_pick "$query")" || rc=$?
    if ((rc == 1)) && [[ -n "$query" ]]; then
      rc=0
      profile="$(fzf_pick "")" || rc=$?
    fi
    ((rc == 0)) && [[ -n "$profile" ]] || exit 1
  fi
  cmd_refresh "$profile"
  printf '%s\n' "$profile"
}

cmd_password() {
  say "Storing the Okta password for ${AWSX_OKTA_USER:?} in the Keychain (service: $KEYCHAIN_SERVICE)."
  security add-generic-password -U -s "$KEYCHAIN_SERVICE" -a "$AWSX_OKTA_USER" -l "awsx Okta password" -w
}

main() {
  local cmd="${1:-}"
  (($#)) && shift
  case "$cmd" in
    login) cmd_login "$@" ;;
    ls) cmd_ls "$@" ;;
    refresh) cmd_refresh "$@" ;;
    pick) cmd_pick "$@" ;;
    password) cmd_password ;;
    "" | -h | --help | help) usage ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
