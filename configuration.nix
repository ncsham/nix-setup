# macOS (nix-darwin) system configuration.
{ config, pkgs, currentUser, self, ... }:
{
  environment.systemPackages = import ./packages.nix { inherit pkgs; };

  # # Not about pkgs.python3 (that is already 3.13). Some other packages still pull python311Packages
  # # transitively (e.g. cassandra, ansible, awscli, black). Sphinx 9.1 is marked incompatible with
  # # py311 in nixpkgs, so that closure fails to evaluate until this override or an upstream fix.
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     python311 = prev.python311.override {
  #       packageOverrides = pyself: pyprev: {
  #         sphinx = pyprev.sphinx.overridePythonAttrs (old: {
  #           disabled = false;
  #         });
  #       };
  #     };
  #     python311Packages = final.python311.pkgs;
  #   })
  # ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    taps = [ "dimentium/autoraise" "tofuutils/tap" ];
    brews = [ "tfenv" "kube-ps1" "node@24" "tofuenv" ];
    casks = [
      "postman"
      "raycast"
      "clipy"
      "orbstack"
      "keepassxc"
      "dimentium/autoraise/autoraiseapp"
      "rectangle"
      "monokle"
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  system.configurationRevision = self.rev or self.dirtyRev or null;
  security.pam.services.sudo_local.touchIdAuth = true;
  system.stateVersion = 6;
  system.primaryUser = currentUser;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;

  system.defaults.LaunchServices.LSQuarantine = false;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.WindowManager.AppWindowGroupingBehavior = true;
  system.defaults.dock.appswitcher-all-displays = true;
  system.defaults.dock.autohide = true;
  system.defaults.dock.wvous-br-corner = null;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.FXPreferredViewStyle = "clmv";
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  users.users.${currentUser} = {
    name = currentUser;
    home = "/Users/${currentUser}";
  };
}
