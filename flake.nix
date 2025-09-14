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
    currentUser = "nitheeshchandrashamanthu";
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.fastfetch
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
        pkgs.kubectx
        pkgs.stern
        pkgs.dive
        pkgs.dust
        pkgs.oci-cli
        pkgs.jsonnet
        pkgs.jsonnet-bundler
        pkgs.kubecolor
        pkgs.curlie
        pkgs.dive
        pkgs.sops
        pkgs.packer
        pkgs.shfmt
        pkgs.envsubst
        pkgs.gojsontoyaml
        pkgs.pwgen
        pkgs.cassandra
        pkgs.kafkactl
        pkgs.oh-my-posh
        pkgs.zsh-syntax-highlighting
        pkgs.zsh-autosuggestions
        
        # Enhanced git diff tools
        pkgs.delta          # Modern diff viewer with syntax highlighting
        pkgs.difftastic     # Structural diff tool that understands syntax
        
        # Language servers for Neovim
        pkgs.pyright                       # Python
        pkgs.gopls                         # Go
        pkgs.bash-language-server          # Bash
        pkgs.lua-language-server           # Lua
        pkgs.yaml-language-server          # YAML
        pkgs.vscode-langservers-extracted  # JSON, HTML, CSS
        
        # Formatters and linters
        pkgs.black                         # Python formatter
        pkgs.gofumpt                       # Go formatter
        pkgs.shellcheck                    # Shell script linter
        pkgs.stylua                        # Lua formatter
        pkgs.nodePackages.prettier         # General formatter
      ];
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        taps = ["dimentium/autoraise"];
        brews = ["tfenv" "kube-ps1" "node@24"];
        casks = ["postman" "raycast" "clipy" "orbstack" "keepassxc" "dimentium/autoraise/autoraiseapp" "rectangle"];
      };
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;
      programs.zsh.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      security.pam.services.sudo_local.touchIdAuth = true;
      system.stateVersion = 6;
      system.primaryUser = currentUser;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nix.enable = false;
      users.users.${currentUser} = {
        name = currentUser;
        home = "/Users/${currentUser}";
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
          home-manager.users.${currentUser} = { pkgs, ... }: {
            imports = [ ./nvim.nix ];
            home.homeDirectory = "/Users/${currentUser}";
            home.username = currentUser;
            home.stateVersion = "24.05";
            programs.git = {
              enable = true;
              extraConfig = {
                core = {
                  pager = "delta";  # Use delta as pager but configure it properly
                  editor = "nvim";
                };
                interactive = {
                  diffFilter = "delta --color-only";
                };
                delta = {
                  navigate = true;
                  light = false;
                  side-by-side = true;
                  line-numbers = true;
                  syntax-theme = "Dracula";
                };
                color = {
                  ui = "auto";
                  diff = "auto";
                  status = "auto";
                  branch = "auto";
                };
                diff = {
                  colorMoved = "default";
                  algorithm = "patience";
                };
                merge = {
                  conflictstyle = "diff3";
                };
                pull = {
                  rebase = false;
                };
                push = {
                  default = "simple";
                  autoSetupRemote = true;
                };
                init = {
                  defaultBranch = "main";
                };
                alias = {
                  st = "status";
                  co = "checkout";
                  br = "branch";
                  ci = "commit";
                  df = "diff";
                  lg = "log --oneline --graph --decorate --all";
                  last = "log -1 HEAD";
                  unstage = "reset HEAD --";
                  visual = "!gitk";
                };
              };
            };
            programs.zsh = {
              enable = true;
              shellAliases = {
                vim = "nvim";
                ls = "eza";
                ll = "ls -lah";
                cat = "bat --paging=never --theme=Dracula";
                grep = "rg";
                nu = "sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'";
                # Package update aliases
                nix-update = "sudo nix flake update /private/etc/nix-darwin && sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'";
                brew-update = "brew update && brew upgrade && brew cleanup";
                system-update = "echo 'Updating Homebrew...' && brew update && brew upgrade && brew cleanup && echo 'Updating Nix packages...' && sudo nix flake update /private/etc/nix-darwin && sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin' && echo 'All updates complete!'";
                g = "git";
                ga = "git add";
                gd = "git diff";
                gs = "git status";
                gc = "git commit -m";
                gpu = "git push";
                gp = "git pull";
                # Enhanced diff aliases
                gdelta = "git diff";  # Delta will be used automatically now
                gdiff = "difft";  # Use difftastic for structural diffs
                gdnp = "git --no-pager diff";  # Plain diff without delta
                curl = "curlie";
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
                code = "open -a Windsurf";
                dcl = "docker container ls -a";
                dil = "docker image ls -a";
                doc = "docker";
                tf = "terraform";
                kctl = "kafkactl";
              };
              initContent = ''
                # ============================================================================
                # SHELL INITIALIZATION CONFIGURATION
                # ============================================================================
                
                # Zsh options (previously from prezto)
                setopt AUTO_CD                    # Change directory by typing directory name
                setopt CORRECT                    # Correct commands
                setopt CORRECT_ALL                # Correct all arguments
                setopt HIST_IGNORE_DUPS           # Ignore duplicate commands in history
                setopt HIST_IGNORE_ALL_DUPS       # Remove older duplicate entries from history
                setopt HIST_REDUCE_BLANKS         # Remove superfluous blanks from history items
                setopt HIST_SAVE_NO_DUPS          # Don't save duplicate entries to history file
                setopt HIST_VERIFY                # Show command with history expansion to user before running
                setopt SHARE_HISTORY              # Share history between all sessions
                setopt EXTENDED_HISTORY           # Write the history file in the ':start:elapsed;command' format
                setopt APPEND_HISTORY             # Append history to the history file (no overwriting)
                setopt INC_APPEND_HISTORY         # Write to the history file immediately, not when the shell exits
                setopt AUTO_PUSHD                 # Push the current directory visited on the stack
                setopt PUSHD_IGNORE_DUPS          # Do not store duplicates in the stack
                setopt PUSHD_SILENT               # Do not print the directory stack after pushd or popd
                setopt GLOB_DOTS                  # Include dotfiles in globbing
                setopt EXTENDED_GLOB              # Use extended globbing syntax
                setopt NO_BEEP                    # Disable beeping
                setopt INTERACTIVE_COMMENTS       # Allow comments in interactive shell
                setopt MULTIOS                    # Perform implicit tees or cats when multiple redirections are attempted
                setopt PROMPT_SUBST               # Enable parameter expansion, command substitution, and arithmetic expansion in prompts
                
                # ----------------------------------------------------------------------------
                # Basic Environment Setup
                # ----------------------------------------------------------------------------
                
                # Source custom functions
                source ~/.functions
                
                # Enable Homebrew environment
                eval "$(/opt/homebrew/bin/brew shellenv)"

                # Enable oh-my-posh with custom theme
                eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/custom.json)"
                
                # Enable zsh plugins
                source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
                
                # ----------------------------------------------------------------------------
                # Key Bindings Configuration
                # ----------------------------------------------------------------------------
                
                # Enable emacs-style key bindings (required for custom bindings)
                bindkey -e
                
                # Word navigation (Option + Arrow keys)
                bindkey "^[^[[C" forward-word        # Option + Right Arrow
                bindkey "^[^[[D" backward-word       # Option + Left Arrow
                bindkey "^[[1;3C" forward-word       # Option + Right Arrow (alternative)
                bindkey "^[[1;3D" backward-word      # Option + Left Arrow (alternative)
                
                # Load persistent AWS profile if exists
                if [[ -f ~/.awsp && -s ~/.awsp ]]; then
                  export AWS_PROFILE=$(cat ~/.awsp)
                fi
                
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
              
              # dec - docker exec container
              # Usage: dec <container_name>
              function dec() {
                if [ $# -ne 1 ]; then
                  echo "Usage: dec <container_name>"
                  return 1
                fi
                # Single exec with shell fallback logic
                docker exec -it "$1" sh -c 'exec /bin/bash 2>/dev/null || exec /bin/sh 2>/dev/null || exec bash 2>/dev/null || exec sh 2>/dev/null || (echo "No shell found"; exit 1)'
              }
              
              # dps - docker ps with better formatting
              function dps() {
                docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
              }
              
              # dclean - clean up docker resources
              function dclean() {
                echo "Cleaning up Docker resources..."
                docker system prune -f
                docker volume prune -f
                docker network prune -f
                echo "Docker cleanup complete!"
              }
              
              # dlf - follow logs with timestamp
              function dlf() {
                if [ $# -eq 0 ]; then
                  echo "Usage: dlf <container_name_or_id>"
                  return 1
                fi
                docker logs -f --timestamps "$1"
              }

              # pck - check if port is open
              function pck() {
                if [ $# -ne 2 ]; then
                  echo "Usage: pck <host> <port>"
                  return 1
                fi
                nc -zv "$1" "$2"
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
            # Oh My Posh theme configuration
            home.file.".config/oh-my-posh/custom.json".text = ''
              {
                "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
                "version": 2,
                "tooltips_action": "extend",
                "tooltips": [
                  {
                    "type": "git",
                    "tips": ["git", "g"],
                    "style": "plain",
                    "foreground": "#f8bbd9",
                    "template": " {{ .HEAD }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}",
                    "properties": {
                      "fetch_status": true,
                      "fetch_upstream_icon": true
                    }
                  },
                  {
                    "type": "aws",
                    "tips": ["aws", "terraform", "tf"],
                    "style": "plain",
                    "foreground": "#ffcc66",
                    "template": " {{.Profile}}{{if .Region}}@{{.Region}}{{end}}"
                  }
                ],
                "blocks": [
                  {
                    "alignment": "left",
                    "segments": [
                      {
                        "type": "path",
                        "style": "plain",
                        "foreground": "#ffff00",
                        "template": "<#dda0dd>.-(</#dda0dd><#00ff00>{{ .Path }}</><#dda0dd>)</>",
                        "properties": {
                          "style": "agnoster_full"
                        }
                      }
                    ],
                    "type": "prompt"
                  },
                  {
                    "alignment": "right",
                    "filler": "<#dda0dd>-</>",
                    "segments": [
                      {
                        "type": "kubectl",
                        "style": "plain",
                        "foreground": "#00bfff",
                        "template": "<#00bfff>(⎈ |{{ .Context }}{{ if .Namespace }}:{{ .Namespace }}{{ end }})</>"
                      },
                      {
                        "type": "executiontime",
                        "style": "plain",
                        "foreground": "#87ceeb",
                        "template": "<#87ceeb>-{{ .FormattedMs }}</>",
                        "properties": {
                          "threshold": 1,
                          "style": "austin"
                        }
                      },
                      {
                        "type": "time",
                        "style": "plain",
                        "foreground": "#dda0dd",
                        "template": "<#dda0dd>-{{ .CurrentDate | date \"15:04:05\" }}-</>"
                      }
                    ],
                    "type": "prompt"
                  },
                  {
                    "alignment": "left",
                    "newline": true,
                    "segments": [
                      {
                        "type": "text",
                        "style": "plain",
                        "foreground": "#dda0dd",
                        "template": "`--> "
                      }
                    ],
                    "type": "prompt"
                  }
                ]
              }
            '';
          };
        }
      ];
    };
  };
}