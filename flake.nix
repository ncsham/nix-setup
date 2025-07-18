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
        pkgs.minikube
        pkgs.k9s
        pkgs.kubectx
        pkgs.stern
        pkgs.dive
        pkgs.dust
        pkgs.oci-cli
        pkgs.jsonnet
        pkgs.jsonnet-bundler
        pkgs.kubecolor
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
    darwinConfigurations."darwin" = nix-darwin.lib.darwinSystem {
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
                nu = "sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'";
                g = "git";
                ga = "git add";
                gd = "git diff";
                gs = "git status";
                gc = "git commit -m";
                gpu = "git push";
                gp = "git pull";
                k = "kubecolor";
                kubectl = "kubecolor";
                ssp = "cp ~/.ssh/config_personal ~/.ssh/config";
                ssw = "cp ~/.ssh/config_work ~/.ssh/config";
                lens = "open -a Lens";
                arc = "open -a Arc";
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
                KUBE_PS1_SYMBOL_ENABLE=true
                KUBE_PS1_PREFIX='('
                KUBE_PS1_SUFFIX=')'
                # Set prezto theme first
                zstyle ':prezto:module:prompt' theme 'adam2'
                # Use prezto's precmd hook to add kube-ps1 after theme loads
                autoload -Uz add-zsh-hook
                # Store original RPROMPT to avoid accumulation
                _original_rprompt="$RPROMPT"
                _kube_ps1_update_prompt() {
                  # Reset to original RPROMPT first
                  RPROMPT="$_original_rprompt"
                  # Add kube-ps1 if kubectl context exists
                  if kubectl config current-context &>/dev/null; then
                    RPROMPT="$(kube_ps1)$RPROMPT"
                  fi
                }
                add-zsh-hook precmd _kube_ps1_update_prompt
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
                export AWS_DEFAULT_REGION=ap-south-1
              '';
            };
            home.file.".functions".text = ''
              function hello() {
                echo "Hello, $1!"
              }
              
              # Kubectl convenience functions
              # ktp - kubectl tail logs of pods
              # Usage: ktp <namespace> <pod-name>
              function ktp() {
                if [ $# -ne 2 ]; then
                  echo "Usage: ktp <namespace> <pod-name>"
                  return 1
                fi
                kubectl logs -f "$2" -n "$1"
              }
              
              # klp - kubectl logs of pods
              # Usage: klp <namespace> <pod-name>
              function klp() {
                if [ $# -ne 2 ]; then
                  echo "Usage: klp <namespace> <pod-name>"
                  return 1
                fi
                kubectl logs "$2" -n "$1"
              }
              
              # kep - kubectl exec pod
              # Usage: kep <namespace> <pod-name>
              function kep() {
                if [ $# -ne 2 ]; then
                  echo "Usage: kep <namespace> <pod-name>"
                  return 1
                fi
                kubectl exec -it "$2" -n "$1" -- /bin/bash
              }
              
              # kgp - kubectl get pods
              # Usage: kgp <namespace> <pod-name-pattern>
              function kgp() {
                if [ $# -eq 0 ]; then
                  kubectl get pods --all-namespaces
                elif [ $# -eq 1 ]; then
                  kubectl get pods -n "$1"
                elif [ $# -eq 2 ]; then
                  kubectl get pods -n "$1" | grep "$2"
                else
                  echo "Usage: kgp [namespace] [pod-name-pattern]"
                  return 1
                fi
              }
            '';
            # Configure bat
            home.file.".config/bat/config".text = ''
              --theme=Dracula
              --style=numbers,changes
            '';
            home.file.".ssh/config_work".text = ''
              Include ~/.orbstack/ssh/config
              Host github.com
                AddKeysToAgent yes
                UseKeychain yes
                IdentityFile ~/.ssh/id_ed25519_work
            '';
            home.file.".ssh/config_personal".text = ''
              Include ~/.orbstack/ssh/config
              Host github.com
                AddKeysToAgent yes
                UseKeychain yes
                IdentityFile ~/.ssh/id_ed25519
            '';
          };
        }
      ];
    };
  };
}