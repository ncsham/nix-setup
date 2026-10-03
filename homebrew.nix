# Homebrew packages managed via nix-darwin (GUI apps and formulae not in nixpkgs).
# Edit these lists and rebuild to add/remove taps, brews and casks.
{
  enable = true;
  enableZshIntegration = true;
  onActivation.cleanup = "uninstall";
  global.autoUpdate = false;

  taps = [
    "dimentium/autoraise"
    "tofuutils/tap"
  ];

  brews = [
    "tfenv"
    "kube-ps1"
    "tofuenv"
    "graphviz"
    "ffmpeg"
  ];

  casks = [
    "clipy"
    "orbstack"
    "keepassxc"
    "dimentium/autoraise/autoraiseapp"
    "rectangle"
    "monokle"
    "temurin"
    "sqlcl"
    "session-manager-plugin"
    "temurin@11"
  ];
}
