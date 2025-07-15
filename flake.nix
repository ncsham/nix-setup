{
  description = "NCShams Default Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.neofetch
        pkgs.neovim
        pkgs.git
        pkgs.htop
        pkgs.tmux
        pkgs.mycli
        pkgs.bat
        pkgs.eza
        pkgs.python3
        pkgs.go
        pkgs.kubectl
        pkgs.kubernetes-helm
        pkgs.fzf
        pkgs.ripgrep
        pkgs.yq-go
        pkgs.jq
        # pkgs.lens # Kubernetes IDE
        # pkgs.keepassxc # Password manager
        # pkgs.postman # API development tool
        # Note: homebrew is not available in nixpkgs for aarch64-darwin.
        # Install Homebrew manually with:
        # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Then use Homebrew to install OrbStack, Raycast, and Clipy.
      ];
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        taps = ["dimentium/autoraise"];
        brews = [];
        casks = ["lens" "postman" "raycast" "clipy" "orbstack" "keepassxc" "dimentium/autoraise/autoraiseapp"];
      };
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;
      programs.zsh.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      security.pam.services.sudo_local.touchIdAuth = true;
      system.stateVersion = 6;
      system.primaryUser = "nitheeshchandrashamanthu";
      nixpkgs.hostPlatform = "aarch64-darwin";
      nix.enable = false;
      users.users.nitheeshchandrashamanthu = {
        name = "nitheeshchandrashamanthu";
        home = "/Users/nitheeshchandrashamanthu";
      };
    };
  in
  {
    darwinConfigurations."NT-IT-LT-3209" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nitheeshchandrashamanthu = { pkgs, ... }: {
            home.homeDirectory = "/Users/nitheeshchandrashamanthu";
            home.username = "nitheeshchandrashamanthu";
            home.stateVersion = "24.05";
            programs.zsh = {
              enable = true;
              prezto = {
                enable = true;
                prompt.theme = "adam2";
                pmodules = ["terminal" "completion" "directory" "syntax-highlighting" "autosuggestions" "osx" "utility" "prompt"];
              };
              shellAliases = {
                gs = "git status";
                vim = "nvim";
                ls = "eza";
                ll = "ls -lah";
                cat = "bat --paging=never --theme=Dracula";
                grep = "rg";
                nu = "sudo darwin-rebuild switch";
                lens = "open -a Lens"; # Launch Lens
                keepassxc = "open -a KeePassXC"; # Launch KeePassXC
                postman = "open -a Postman"; # Launch Postman
                orbstack = "open -a OrbStack"; # Launch OrbStack (after Homebrew install)
                raycast = "open -a Raycast"; # Launch Raycast (after Homebrew install)
                clipy = "open -a Clipy"; # Launch Clipy (after Homebrew install)
                code = "open -a Windsurf"; # Launch Windsurf (after Homebrew install)
              };
              initContent = ''
                # Source custom functions
                source ~/.functions

                # Enable fzf key bindings for Ctrl+R history search
                source ${pkgs.fzf}/share/fzf/key-bindings.zsh
                source ${pkgs.fzf}/share/fzf/completion.zsh

                # Enable kubectl and helm completions
                source <(kubectl completion zsh)
                source <(helm completion zsh)

                # fzf and history settings
                export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'
                export HISTSIZE=10000
                export SAVEHIST=100000
                export SHARE_HISTORY=true
              '';
            };
            home.file.".functions".text = ''
              function hello() {
                echo "Hello, $1!"
              }
            '';
          };
        }
      ];
    };
  };
}