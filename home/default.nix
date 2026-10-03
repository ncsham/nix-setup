# Home Manager config: entry point that imports all user modules.
{ pkgs, currentUser, ... }:
{
  imports = [
    ./nvim.nix
    ./git.nix
    ./zsh.nix
    ./functions.nix
    ./bat.nix
    ./ssh.nix
    ./wezterm.nix
    ./oh-my-posh.nix
    ./vscode.nix
  ];

  home.homeDirectory = "/Users/${currentUser}";

  # Extra directories prepended to PATH (e.g. uv-installed tools like spec-kit).
  home.sessionPath = [ "$HOME/.local/bin" ];

    # The state version is required and should stay at the version you originally installed.
  home.stateVersion = "26.05";
}
