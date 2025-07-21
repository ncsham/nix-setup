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
        pkgs.kubectx
      ];
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        taps = ["dimentium/autoraise"];
        brews = ["tfenv" "kube-ps1" "node@24"];
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
                kd = "kubecolor diff -f";
                ka = "kubecolor apply -f";
                ssp = "cp ~/.ssh/config_personal ~/.ssh/config";
                ssw = "cp ~/.ssh/config_work ~/.ssh/config";
                ktx = "kubectx";
                kns = "kubens";
                awsp = "source _awsp";
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
                # ============================================================================
                # SHELL INITIALIZATION CONFIGURATION
                # ============================================================================
                
                # ----------------------------------------------------------------------------
                # Basic Environment Setup
                # ----------------------------------------------------------------------------
                
                # Source custom functions
                source ~/.functions
                
                # Enable Homebrew environment
                eval "$(/opt/homebrew/bin/brew shellenv)"
                
                # Load persistent AWS profile if exists
                if [[ -f ~/.awsp && -s ~/.awsp ]]; then
                  export AWS_PROFILE=$(cat ~/.awsp)
                fi
                
                # ----------------------------------------------------------------------------
                # Prompt Configuration
                # ----------------------------------------------------------------------------
                
                # Source kube-ps1 for Kubernetes context in prompt
                source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh
                
                # Customize kube-ps1 settings
                KUBE_PS1_SYMBOL_ENABLE=true
                KUBE_PS1_PREFIX='('
                KUBE_PS1_SUFFIX=')'
                
                # Set prezto theme
                zstyle ':prezto:module:prompt' theme 'adam2'
                
                # Use prezto's precmd hook to add custom prompt elements
                autoload -Uz add-zsh-hook
                
                # AWS Profile display function (similar to kube-ps1)
                aws_ps1() {
                  if [[ -n "$AWS_PROFILE" ]]; then
                    echo "(%{$fg[green]%}☁|$AWS_PROFILE%{$reset_color%})"
                  fi
                }
                
                # Store original RPROMPT to avoid accumulation
                _original_rprompt="$RPROMPT"
                
                # Custom prompt update function
                _kube_aws_ps1_update_prompt() {
                  # Reset to original RPROMPT first
                  RPROMPT="$_original_rprompt"
                  
                  # Direct kubectl context check for real-time accuracy
                  if kubectl config current-context &>/dev/null; then
                    RPROMPT="$(kube_ps1)$(aws_ps1)$RPROMPT"
                  else
                    # If no k8s context, just show AWS profile
                    RPROMPT="$(aws_ps1)$RPROMPT"
                  fi
                }
                
                # Hook the prompt update function
                add-zsh-hook precmd _kube_aws_ps1_update_prompt
                
                # ----------------------------------------------------------------------------
                # Async Completion Loading (Performance Optimization)
                # ----------------------------------------------------------------------------
                
                # Load kubectl and helm completions asynchronously in background
                {
                  # Load kubectl completion if kubectl is available
                  if command -v kubectl >/dev/null 2>&1; then
                    source <(kubectl completion zsh) 2>/dev/null
                  fi
                  
                  # Load helm completion if helm is available
                  if command -v helm >/dev/null 2>&1; then
                    source <(helm completion zsh) 2>/dev/null
                  fi
                } &!
                
                # ----------------------------------------------------------------------------
                # FZF Configuration
                # ----------------------------------------------------------------------------
                
                # Load fzf key bindings and completion
                source ${pkgs.fzf}/share/fzf/key-bindings.zsh 2>/dev/null
                source ${pkgs.fzf}/share/fzf/completion.zsh 2>/dev/null
                
                # FZF appearance and behavior settings
                export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height 50% --layout=reverse --border'
                export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
                
                # ----------------------------------------------------------------------------
                # Shell History Configuration
                # ----------------------------------------------------------------------------
                
                export HISTSIZE=10000
                export SAVEHIST=100000
                export SHARE_HISTORY=true
                
                # ----------------------------------------------------------------------------
                # AWS Configuration
                # ----------------------------------------------------------------------------
                
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
                kubecolor logs -f "$2" -n "$1"
              }
              
              # klp - kubectl logs of pods
              # Usage: klp <namespace> <pod-name>
              function klp() {
                if [ $# -ne 2 ]; then
                  echo "Usage: klp <namespace> <pod-name>"
                  return 1
                fi
                kubecolor logs "$2" -n "$1"
              }
              
              # kep - kubectl exec pod
              # Usage: kep <namespace> <pod-name>
              function kep() {
                if [ $# -ne 2 ]; then
                  echo "Usage: kep <namespace> <pod-name>"
                  return 1
                fi
                # Single exec with shell fallback logic
                kubecolor exec -it "$2" -n "$1" -- sh -c 'exec /bin/bash 2>/dev/null || exec /bin/sh 2>/dev/null || exec bash 2>/dev/null || exec sh 2>/dev/null || (echo "No shell found"; exit 1)'
              }
              
              # kgp - kubectl get pods
              # Usage: kgp <namespace> <pod-name-pattern>
              function kgp() {
                if [ $# -eq 0 ]; then
                  kubecolor get pods --all-namespaces
                elif [ $# -eq 1 ]; then
                  kubecolor get pods -n "$1"
                elif [ $# -eq 2 ]; then
                  kubecolor get pods -n "$1" | grep "$2"
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