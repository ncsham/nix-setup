# Home Manager config: entry point that imports all user modules.
{ pkgs, currentUser, ... }:
{
  imports = [
    ../nvim.nix
    ./git.nix
    ./zsh.nix
    ./functions.nix
    ./bat.nix
    ./ssh.nix
    ./wezterm.nix
    ./oh-my-posh.nix
  ];

  home.homeDirectory = "/Users/${currentUser}";
  home.stateVersion = "24.05";
}
