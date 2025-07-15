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
        pkgs.awscli
        pkgs.opentofu
        pkgs.kops
        pkgs.ansible
        pkgs.prometheus
        pkgs.tree
        pkgs.rsync
        pkgs.wget
        pkgs.docker-compose
        pkgs.ncdu
        pkgs.postgresql
      ];
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        taps = ["dimentium/autoraise"];
        brews = ["tfenv" "kube-ps1"];
        casks = ["lens" "postman" "raycast" "clipy" "orbstack" "keepassxc" "dimentium/autoraise/autoraiseapp" "rectangle"];
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
                pmodules = [
                  "environment"
                  "terminal"
                  "completion"
                  "directory"
                  "syntax-highlighting"
                  "autosuggestions"
                  "osx"
                  "utility"
                  "prompt"
                ];
              };
              shellAliases = {
                vim = "nvim";
                ls = "eza";
                ll = "ls -lah";
                cat = "bat --paging=never --theme=Dracula";
                grep = "rg";
                nu = "sudo darwin-rebuild switch";
                ga = "git add";
                gd = "git diff";
                gs = "git status";
                gc = "git commit -m";
                gpu = "git push";
                gp = "git pull";
                lens = "open -a Lens";
                keepassxc = "open -a KeePassXC";
                postman = "open -a Postman";
                orbstack = "open -a OrbStack";
                raycast = "open -a Raycast";
                clipy = "open -a Clipy";
                code = "open -a Windsurf"; # Note: Windsurf may not be correct; replace with actual app name (e.g., "Visual Studio Code")
              };
              initContent = ''
                # Source custom functions
                source ~/.functions
                # Enable Homebrew environment
                eval "$(/opt/homebrew/bin/brew shellenv)"
                # Source kube-ps1 for Kubernetes context in prompt
                source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh
                # Customize kube-ps1 settings
                KUBE_PS1_SYMBOL_ENABLE=false
                KUBE_PS1_PREFIX='('
                KUBE_PS1_SUFFIX=')'
                # Integrate kube-ps1 with adam2 prompt
                zstyle ':prezto:module:prompt' theme 'adam2'
                PROMPT='$(kube_ps1)'$PROMPT
                # Enable fzf key bindings for Ctrl+R history search
                source ${pkgs.fzf}/share/fzf/key-bindings.zsh
                source ${pkgs.fzf}/share/fzf/completion.zsh
                # Enable kubectl and helm completions
                source <(kubectl completion zsh)
                source <(helm completion zsh)
                # fzf and history settings
                export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'
                export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
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
            # Configure bat
            home.file.".config/bat/config".text = ''
              --theme=Dracula
              --style=numbers,changes
            '';
          };
        }
      ];
    };
  };
}