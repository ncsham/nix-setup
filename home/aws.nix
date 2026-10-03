# awsx: one AWS profile per account behind Okta SAML tiles (awslogin / awsp / awsx).
# Enabled and configured from the private flake input (see flake.nix).
{ config, pkgs, lib, ... }:
let
  cfg = config.programs.awsx;

  # Okta Identity Engine sign-in (password + Okta Verify push), SAML roles, STS.
  awsxOkta = pkgs.writers.writePython3Bin "awsx-okta" { flakeIgnore = [ "E501" ]; }
    (builtins.readFile ./aws/awsx_okta.py);

  awsx = pkgs.writeShellApplication {
    name = "awsx";
    runtimeInputs = [ awsxOkta pkgs.fzf pkgs.gawk pkgs.coreutils ];
    runtimeEnv = {
      AWSX_TILES = lib.concatStringsSep " " (lib.mapAttrsToList (name: url: "${name}=${url}") cfg.tiles);
      AWSX_OKTA_USER = cfg.oktaUser;
    };
    text = builtins.readFile ./aws/awsx.sh;
  };
in
{
  options.programs.awsx = {
    enable = lib.mkEnableOption "awsx, AWS profiles from Okta SAML tiles";
    oktaUser = lib.mkOption {
      type = lib.types.str;
      description = "Okta username (the Keychain password is stored with `awsx password`).";
    };
    tiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        Okta AWS tiles: short name -> tile link (Okta dashboard -> tile -> copy link).
        The short name is shown in `awsx ls` and accepted by `awslogin <tile>`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ awsx ];

    programs.zsh.initContent = ''
      # awsp must be a function so it can export AWS_PROFILE into this shell.
      awsp() {
        local profile
        profile="$(awsx pick "$@")" || return
        export AWS_PROFILE="$profile"
        print -r -- "$profile" >| ~/.awsp
        print -r -- "AWS_PROFILE=$profile"
      }
      awslogin() { awsx login "$@"; }
      _awsp() {
        local -a profiles
        [[ -r ~/.aws/awsx/accounts.tsv ]] && profiles=(''${(f)"$(cut -f1 ~/.aws/awsx/accounts.tsv)"})
        compadd -a profiles
      }
      compdef _awsp awsp
    '';
  };
}
