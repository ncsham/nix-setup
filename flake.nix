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
        pkgs.zsh-fast-syntax-highlighting
        pkgs.zsh-autosuggestions
        pkgs.zsh-fzf-tab
        pkgs.zoxide
        pkgs.zsh-forgit
        pkgs.wezterm
        
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
        taps = ["dimentium/autoraise" "tofuutils/tap"];
        brews = ["tfenv" "kube-ps1" "node@24" "tofuenv"];
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
                
                # Nix package management
                nup = "sudo nix flake update --flake /private/etc/nix-darwin";  # Update flake.lock
                nugp = "sudo darwin-rebuild build --flake '/private/etc/nix-darwin#darwin' && nix store diff-closures /nix/var/nix/profiles/system /private/etc/nix-darwin/result";  # Preview changes
                nug = "sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'";  # Apply changes
                
                # Homebrew package management
                bu = "brew update";  # Update brew formulae
                bug = "brew upgrade && brew cleanup";  # Upgrade packages and cleanup
                
                # Combined system updates
                sysup = "brew update && sudo nix flake update --flake /private/etc/nix-darwin";  # Update both systems
                sysugp = "sudo darwin-rebuild build --flake '/private/etc/nix-darwin#darwin' && nix store diff-closures /nix/var/nix/profiles/system /private/etc/nix-darwin/result";  # Preview all changes
                sysug = "brew upgrade && brew cleanup && sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'";  # Upgrade everything
                g = "git";
                # Note: ga, gd, glo, gco, gcf, gcb, etc. are provided by forgit for interactive use
                # Using different aliases for basic git commands to avoid conflicts
                gad = "git add";     # Use gad instead of ga to avoid conflict with forgit
                gdi = "git diff";    # Use gdi instead of gd to avoid conflict with forgit  
                gs = "git status";
                gc = "git commit -m";
                gpu = "git push origin";
                gp = "git pull";
                gcm = "git checkout master";
                gcbn = "git checkout -b";  # Use gcbn instead of gcb to avoid conflict with forgit
                # Enhanced diff aliases
                gdelta = "git diff";  # Delta will be used automatically now
                gdiff = "difft";  # Use difftastic for structural diffs
                gdnp = "git --no-pager diff";  # Plain diff without delta
                # Forgit provides these interactive commands directly: ga, glo, gd, gco, gcf, gcb, grh, gss, gsp
                # No need for additional aliases - forgit commands will be available after sourcing
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
                cd = "z";
                cdi = "zi";
                wezterm = "open -a WezTerm";
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
                
                # Enable zsh plugins (order matters!)
                # Load fzf-tab first (after compinit, before other plugins)
                source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
                
                # Configure fzf-tab to use your existing fzf theme
                zstyle ':fzf-tab:*' fzf-command fzf
                zstyle ':fzf-tab:*' fzf-flags '--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9' '--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9' '--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6' '--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4' '--height=50%' '--layout=reverse' '--border'
                
                # Load other plugins after fzf-tab
                source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
                
                # Enable zoxide (smart directory jumping)
                eval "$(zoxide init zsh)"
                
                # ----------------------------------------------------------------------------
                # Forgit Configuration (Interactive Git with FZF)
                # ----------------------------------------------------------------------------
                
                # Forgit configuration options (set before sourcing)
                export FORGIT_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height=80% --preview-window=right:60%"
                export FORGIT_LOG_GRAPH_ENABLE=true
                export FORGIT_COPY_CMD='pbcopy'  # macOS clipboard command
                
                # Source forgit for interactive git commands (after setting options)
                source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh
                
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

              # kexec-multi - Execute commands across multiple Kubernetes pods
              # Usage: kexec-multi [--dry-run] <namespace> <pod-pattern> <command>
              # Examples:
              #   kexec-multi prod navipay-customer-profile-navi-service date
              #   kexec-multi --dry-run prod valhalla-navi-service "date +%s"
              #   kexec-multi prod navipay-customer-profile-navi-service uptime
              function kexec-multi() {
                local dry_run=false
                local namespace=""
                local pod_pattern=""
                local command=""
                
                # Parse arguments
                while [[ $# -gt 0 ]]; do
                  case $1 in
                    --dry-run)
                      dry_run=true
                      shift
                      ;;
                    *)
                      if [[ -z "$namespace" ]]; then
                        namespace="$1"
                      elif [[ -z "$pod_pattern" ]]; then
                        pod_pattern="$1"
                      else
                        command="$*"
                        break
                      fi
                      shift
                      ;;
                  esac
                done
                
                # Validate arguments
                if [[ -z "$namespace" || -z "$pod_pattern" || -z "$command" ]]; then
                  echo "Usage: kexec-multi [--dry-run] <namespace> <pod-pattern> <command>"
                  echo ""
                  echo "Options:"
                  echo "  --dry-run    Show what would be executed without running"
                  echo ""
                  echo "Examples:"
                  echo "  kexec-multi prod navipay-customer-profile-navi-service date"
                  echo "  kexec-multi --dry-run prod valhalla-navi-service \"date +%s\""
                  echo "  kexec-multi prod navipay-customer-profile-navi-service uptime"
                  return 1
                fi
                
                # Get matching pods
                echo "🔍 Finding pods matching pattern '$pod_pattern' in namespace '$namespace'..."
                local pods=$(kubectl get pods -n "$namespace" --no-headers | grep "$pod_pattern" | awk '{print $1}')
                
                if [[ -z "$pods" ]]; then
                  echo "❌ No pods found matching pattern '$pod_pattern' in namespace '$namespace'"
                  return 1
                fi
                
                local pod_count=$(echo "$pods" | wc -l | tr -d ' ')
                echo "📦 Found $pod_count pods:"
                echo "$pods" | sed 's/^/  - /'
                echo ""
                
                if [[ "$dry_run" == "true" ]]; then
                  echo "🧪 DRY RUN - Commands that would be executed:"
                  echo "$pods" | while read -r pod; do
                    echo "  kubectl exec -n $namespace $pod -- $command"
                  done
                  return 0
                fi
                
                # Execute command on all pods
                echo "🚀 Executing command: $command"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                
                echo "$pods" | while read -r pod; do
                  echo ""
                  echo "📍 Pod: $pod"
                  echo "   ────────────────────────────────────────────────────────────────────────"
                  
                  # Execute and capture result
                  local result=$(kubectl exec -n "$namespace" "$pod" -- sh -c "$command" 2>&1)
                  local exit_code=$?
                  
                  if [[ $exit_code -eq 0 ]]; then
                    echo "   ✅ Success:"
                    echo "$result" | sed 's/^/   │ /'
                  else
                    echo "   ❌ Failed (exit code: $exit_code):"
                    echo "$result" | sed 's/^/   │ /'
                  fi
                done
                
                echo ""
                echo "✨ Execution completed for $pod_count pods"
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
            # WezTerm terminal configuration with Lua mentorship
            home.file.".config/wezterm/wezterm.lua".text = ''
              -- ============================================================================
              -- 🎓 WEZTERM LUA CONFIGURATION - YOUR LUA LEARNING JOURNEY STARTS HERE!
              -- ============================================================================
              -- Welcome to Lua! This config will teach you Lua step by step.
              -- Lua is simple: variables, tables, functions, and that's mostly it!
              
              -- 📚 LUA LESSON 1: IMPORTING MODULES
              -- In Lua, we use 'require' to import modules (like 'import' in Python)
              -- 'local' creates a variable that's only visible in this file
              local wezterm = require 'wezterm'
              
              -- 📚 LUA LESSON 2: TABLES (LIKE OBJECTS/DICTIONARIES)
              -- In Lua, almost everything is a table! Tables are like JSON objects.
              -- We create an empty table to hold our configuration
              local config = {}
              
              -- 📚 LUA LESSON 3: CONDITIONAL LOGIC
              -- We can check WezTerm version and adjust accordingly
              if wezterm.config_builder then
                -- This is the new way (WezTerm 20220807+)
                config = wezterm.config_builder()
              end
              
              -- ============================================================================
              -- 🎨 APPEARANCE CONFIGURATION
              -- ============================================================================
              
              -- 📚 LUA LESSON 4: ASSIGNING VALUES TO TABLE FIELDS
              -- In Lua, we assign values using = (like config.key = value)
              -- Strings use single or double quotes (both work the same)
              -- config.color_scheme = 'Tomorrow Night'  -- Commented out to use default theme
              
              -- 📚 LUA LESSON 5: NUMBERS AND BOOLEANS
              -- Numbers don't need quotes, booleans are true/false (lowercase)
              config.font_size = 23.0
              config.window_background_opacity = 0.50 -- 65% opacity (35% transparency) - perfect balance
              config.macos_window_background_blur = 13 -- Slightly less blur for cleaner look
              
              -- 📚 LUA LESSON 6: CALLING FUNCTIONS
              -- Functions are called with parentheses: function_name(arguments)
              -- wezterm.font() creates a font object
              config.font = wezterm.font('Hack Nerd Font', { weight = 'Regular' })
              
              -- ============================================================================
              -- 🪟 WINDOW CONFIGURATION
              -- ============================================================================
              
              -- Window decorations (title bar style)
              config.window_decorations = "RESIZE"
              
              -- Initial window size
              config.initial_cols = 120
              config.initial_rows = 40
              
              -- Window padding (space around terminal content)
              config.window_padding = {
                left = 10,
                right = 10,
                top = 10,
                bottom = 10,
              }
              
              -- ============================================================================
              -- 📑 TAB BAR CONFIGURATION
              -- ============================================================================
              
              -- Enable the tab bar
              config.enable_tab_bar = true
              
              -- Hide tab bar when only one tab is open
              config.hide_tab_bar_if_only_one_tab = true
              
              -- Tab bar position (true = bottom, false = top)
              config.tab_bar_at_bottom = false
              
              -- Use fancy tab bar (with rounded corners)
              config.use_fancy_tab_bar = true
              
              -- ============================================================================
              -- ⌨️  KEYBOARD SHORTCUTS
              -- ============================================================================
              
              -- 📚 LUA LESSON 7: ARRAYS/LISTS
              -- Arrays in Lua are tables with numeric indices starting at 1 (not 0!)
              -- We create an array of key binding tables
              config.keys = {
                -- 📚 LUA LESSON 8: TABLE CONSTRUCTORS
                -- Each item in this array is a table with key, mods, and action fields
                
                -- Tab management (native WezTerm tabs!)
                {
                  key = 't',
                  mods = 'CMD',
                  action = wezterm.action.SpawnTab 'CurrentPaneDomain',
                },
                {
                  key = 'w',
                  mods = 'CMD',
                  action = wezterm.action.CloseCurrentTab { confirm = true },
                },
                
                -- Pane splitting (native WezTerm splits!)
                {
                  key = 'd',
                  mods = 'CMD',
                  action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
                },
                {
                  key = 'd',
                  mods = 'CMD|SHIFT',
                  action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
                },
                
                -- Pane navigation
                {
                  key = 'LeftArrow',
                  mods = 'CMD',
                  action = wezterm.action.ActivatePaneDirection 'Left',
                },
                {
                  key = 'RightArrow',
                  mods = 'CMD',
                  action = wezterm.action.ActivatePaneDirection 'Right',
                },
                {
                  key = 'UpArrow',
                  mods = 'CMD',
                  action = wezterm.action.ActivatePaneDirection 'Up',
                },
                {
                  key = 'DownArrow',
                  mods = 'CMD',
                  action = wezterm.action.ActivatePaneDirection 'Down',
                },
                
                -- Font size controls
                {
                  key = '=',
                  mods = 'CMD',
                  action = wezterm.action.IncreaseFontSize,
                },
                {
                  key = '-',
                  mods = 'CMD',
                  action = wezterm.action.DecreaseFontSize,
                },
                {
                  key = '0',
                  mods = 'CMD',
                  action = wezterm.action.ResetFontSize,
                },
                
                -- Fullscreen toggle
                {
                  key = 'Enter',
                  mods = 'CMD',
                  action = wezterm.action.ToggleFullScreen,
                },
                
                -- Copy/Paste (WezTerm handles these automatically, but we can customize)
                {
                  key = 'c',
                  mods = 'CMD',
                  action = wezterm.action.CopyTo 'Clipboard',
                },
                {
                  key = 'v',
                  mods = 'CMD',
                  action = wezterm.action.PasteFrom 'Clipboard',
                },
                
                -- Quick select mode (for URLs, file paths, etc.)
                {
                  key = 'Space',
                  mods = 'CMD',
                  action = wezterm.action.QuickSelect,
                },
                
                -- Search mode
                {
                  key = 'f',
                  mods = 'CMD',
                  action = wezterm.action.Search('CurrentSelectionOrEmptyString'),
                },
                
                -- Reload configuration (great for testing changes!)
                {
                  key = 'r',
                  mods = 'CMD|SHIFT',
                  action = wezterm.action.ReloadConfiguration,
                },
                
                -- Word navigation and editing bindings
                {
                  key = 'LeftArrow',
                  mods = 'OPT',
                  action = wezterm.action.SendKey { key = 'b', mods = 'ALT' },
                },
                {
                  key = 'RightArrow',
                  mods = 'OPT',
                  action = wezterm.action.SendKey { key = 'f', mods = 'ALT' },
                },
                {
                  key = 'LeftArrow',
                  mods = 'CTRL',
                  action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
                },
                {
                  key = 'RightArrow',
                  mods = 'CTRL',
                  action = wezterm.action.SendKey { key = 'e', mods = 'CTRL' },
                },
                {
                  key = 'w',
                  mods = 'CTRL',
                  action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' },
                },
                {
                  key = 'Backspace',
                  mods = 'OPT',
                  action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' },
                },
              }
              
              -- ============================================================================
              -- 🖱️  MOUSE CONFIGURATION
              -- ============================================================================
              
              -- Hide mouse cursor when typing
              config.hide_mouse_cursor_when_typing = true
              
              -- ============================================================================
              -- 🎯 CURSOR CONFIGURATION
              -- ============================================================================
              
              -- Enable cursor blinking
              config.default_cursor_style = 'BlinkingBlock'
              config.cursor_blink_rate = 500  -- Blink every 800ms (nice and smooth)
              
              -- ============================================================================
              -- 📜 SCROLLBACK CONFIGURATION
              -- ============================================================================
              
              -- Number of lines to keep in scrollback
              config.scrollback_lines = 1000000
              
              -- ============================================================================
              -- 🔔 BELL CONFIGURATION
              -- ============================================================================
              
              -- Disable the bell (no annoying sounds!)
              config.audible_bell = "Disabled"
              
              -- ============================================================================
              -- 🎯 ADVANCED FEATURES
              -- ============================================================================
              
              -- Enable hyperlink detection (clickable URLs)
              config.hyperlink_rules = wezterm.default_hyperlink_rules()
              
              -- 📚 LUA LESSON 9: ADDING TO ARRAYS
              -- We can add custom hyperlink patterns to the existing ones
              table.insert(config.hyperlink_rules, {
                -- Match things that look like git commit hashes
                regex = [[\b[a-f0-9]{6,40}\b]],
                format = 'https://github.com/search?q=$0&type=commits',
              })
              
              -- ============================================================================
              -- 🎨 CUSTOM COLOR OVERRIDES (OPTIONAL)
              -- ============================================================================
              
              -- 📚 LUA LESSON 10: NESTED TABLES
              -- We can override specific colors to match our dark theme (like iTerm2)
              config.colors = {
                -- Override the tab bar colors for a sleek dark look
                tab_bar = {
                  background = '#1e1e1e',  -- Dark background like VS Code
                  active_tab = {
                    bg_color = '#007acc',   -- Blue accent like VS Code
                    fg_color = '#ffffff',
                    intensity = 'Bold',
                  },
                  inactive_tab = {
                    bg_color = '#2d2d30',   -- Subtle dark gray
                    fg_color = '#cccccc',
                  },
                  inactive_tab_hover = {
                    bg_color = '#3e3e42',   -- Slightly lighter on hover
                    fg_color = '#ffffff',
                  },
                  new_tab = {
                    bg_color = '#1e1e1e',
                    fg_color = '#cccccc',
                  },
                  new_tab_hover = {
                    bg_color = '#2d2d30',
                    fg_color = '#ffffff',
                  },
                },
              }
              
              -- ============================================================================
              -- 🚀 PERFORMANCE OPTIMIZATIONS
              -- ============================================================================
              
              -- Enable GPU acceleration
              config.front_end = "WebGpu"
              
              -- Optimize for better performance
              config.max_fps = 120
              
              -- ============================================================================
              -- 🎓 FINAL LUA LESSON: RETURNING VALUES
              -- ============================================================================
              
              -- In Lua, the last line of a script can return a value
              -- WezTerm expects us to return our configuration table
              -- This is how WezTerm gets all our settings!
              return config
              
              -- 🎉 CONGRATULATIONS! 
              -- You've just learned the basics of Lua through a real-world example!
              -- 
              -- Key Lua concepts you now know:
              -- 1. require() - importing modules
              -- 2. local - creating variables
              -- 3. Tables - Lua's main data structure (like objects/dictionaries)
              -- 4. Arrays - tables with numeric indices
              -- 5. Functions - calling them with parentheses
              -- 6. Conditionals - if/then statements
              -- 7. Comments - using -- for single line, --[[ ]] for multi-line
              -- 8. return - sending values back from functions/scripts
              --
              -- Want to learn more? Try modifying values and see what happens!
              -- Use Cmd+Shift+R to reload the config and see your changes instantly!
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
                        "template": "<#00bfff>(⎈|{{ .Context }}{{ if .Namespace }}:{{ .Namespace }}{{ end }})</>"
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