# macOS (nix-darwin) system configuration.
{ config, pkgs, currentUser, self, ... }:
{
  environment.systemPackages = import ./packages.nix { inherit pkgs; };
  fonts.packages = [ pkgs.nerd-fonts.hack ];

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation.cleanup = "uninstall";
    global.autoUpdate = false;
    taps = [ "dimentium/autoraise" "tofuutils/tap" ];
    brews = [ "tfenv" "kube-ps1" "node@24" "tofuenv" ];
    casks = [
      "postman"
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
  system.defaults.controlcenter.BatteryShowPercentage = true;
  system.defaults.dock.orientation = "right";
  system.defaults.dock.show-recents = false;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;

  users.users.${currentUser} = {
    name = currentUser;
    home = "/Users/${currentUser}";
  };
}
