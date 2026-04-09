# Nix Darwin Flakes

This project provides a comprehensive [Nix Flake](https://nixos.wiki/wiki/Flakes) setup for managing and provisioning a macOS system using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). It is tailored for Apple Silicon (aarch64-darwin) and is designed to make your system configuration reproducible, declarative, and easily portable.

---

## Features

- **Reproducible macOS Configuration**: System and user config are split across a modular flake: `flake.nix`, `configuration.nix`, `packages.nix`, and `home/` for Home Manager.
- **Nix-Darwin Integration**: Leverage the power of Nix to manage macOS like NixOS.
- **Home-Manager**: User-level packages and dotfiles are managed declaratively under `home/` (git, zsh, wezterm, oh-my-posh, etc.).
- **Comprehensive Package Set**: Nix packages live in `packages.nix` (e.g. `go`, `python3`, `awscli`, `kubectl`, `helm`, `minikube`, `kops`, `bat`, `eza`, `fzf`, `ripgrep`, `htop`, `tree`). Homebrew formulae and casks are in `configuration.nix`.
- **Kubernetes Integration**: kubectl/helm completions and custom helper functions (see `home/functions.nix`).
- **Oh-My-Posh**: Prompt theme is defined in YAML at `home/oh-my-posh/custom.yaml` (path, kubectl, time, tooltips).
- **Homebrew Support**: GUI apps and extra CLI tools via Homebrew in `configuration.nix` (Postman, Raycast, OrbStack, etc.).
- **Apple Silicon Ready**: Configured for `aarch64-darwin` (Apple Silicon/M1/M2).

---

## Table of Contents

- [Getting Started](#getting-started)
  - [For Existing nix-darwin Users](#for-existing-nix-darwin-users)
  - [Quick Commands After Setup](#quick-commands-after-setup)
- [Package Management](#package-management)
  - [Quick Update Commands](#quick-update-commands)
  - [Checking for Updates](#checking-for-updates)
  - [Updating Packages](#updating-packages)
  - [Searching for Packages](#searching-for-packages)
  - [Package Sources](#package-sources)
- [Key Components](#key-components)
- [Terraform & tfenv](#terraform--tfenv)
  - [Installing Specific Terraform Versions](#installing-specific-terraform-versions)
- [Kubernetes Helper Functions](#kubernetes-helper-functions)
  - [Available Functions](#available-functions)
  - [Shell Features](#shell-features)
- [Docker Helper Functions](#docker-helper-functions)
- [Terminal Key Bindings](#terminal-key-bindings)
- [Oh-My-Posh Prompt](#oh-my-posh-prompt)
- [Neovim Editor](#neovim-editor)
  - [Key Features](#key-features)
  - [Important Keybindings](#important-keybindings)
  - [Language Server Support](#language-server-support)
- [Included Packages](#included-packages)
  - [Development Tools](#development-tools)
  - [Cloud & Infrastructure](#cloud--infrastructure)
  - [Kubernetes & Container Tools](#kubernetes--container-tools)
  - [System Utilities](#system-utilities)
  - [Homebrew Packages](#homebrew-packages)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [References](#references)
- [Nix language basics (Python comparison)](#nix-language-basics-python-comparison)

---

## Getting Started

*If you're setting up nix-darwin from scratch, see the [Initial Setup from Scratch](#initial-setup-from-scratch) section above.*

### For Existing nix-darwin Users

If you already have nix-darwin installed and want to use this configuration:

1. **Install Nix Installer:**
   ```bash
   curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
   ```

2. **Clone this repository:**
   ```bash
   mkdir -p /etc/nix-darwin && git clone https://github.com/ncsham/nix-setup.git /etc/nix-darwin
   ```

3. **Install Homebrew:**
  Homebrew is needed for GUI applications and some packages not available in nixpkgs:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

4. **Apply the configuration:**
   ```bash
    sudo /usr/bin/env USER="$USER" nix run nix-darwin/master#darwin-rebuild -- switch --impure --flake '/etc/nix-darwin#darwin'
   ```

### Quick Commands After Setup
- **Rebuild (no flake update)**: `nug`
- **Update flake then rebuild**: `nup` then `nug`; or combined: `sysug` (see [Package Management](#package-management))
- **Terraform**: `tfenv list-remote`, `tfenv install <version>`, `tfenv use <version>`
- **Kubernetes**: `kgp`, `klp`, `ktp`, `kep` (see [Kubernetes Helper Functions](#kubernetes-helper-functions))

---

## Package Management

This section provides comprehensive guidance on managing packages in your nix-darwin setup, including both Nix packages and Homebrew packages.

### Quick Update Commands

Shell aliases (defined in `home/zsh.nix`) for updates:

| Alias | Action |
|-------|--------|
| **nup** | Update Nix flake only (`sudo nix flake update --flake /private/etc/nix-darwin`) |
| **nugp** | Build darwin config and show closure diff (preview changes; does not switch) |
| **nug** | Apply current flake (`sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'`) |
| **bu** | `brew update` |
| **bug** | `brew upgrade && brew cleanup` |
| **sysup** | Update both: `brew update` and Nix flake update |
| **sysugp** | Preview: build darwin and show closure diff (no switch) |
| **sysug** | Full upgrade: Homebrew upgrade + cleanup, then darwin-rebuild switch |

**Usage examples:**
```bash
# Update flake, then rebuild
nup && nug

# Rebuild only (no updates)
nug

# Update Homebrew
bu && bug

# Update everything and switch
sysug
```

### Checking for Updates

#### Nix Package Updates

**Check what packages have updates available:**
```bash
# See what packages would be updated (dry run)
sudo nix flake update /private/etc/nix-darwin --dry-run

# Check specific package version
nix-env -qa | grep <package-name>

# Check installed vs available versions
nix-env --query --available --compare-versions | grep <package-name>
```

**Check flake inputs for updates:**
```bash
# View current flake lock information
nix flake metadata /private/etc/nix-darwin

# Check for newer commits in nixpkgs
nix flake show /private/etc/nix-darwin
```

#### Homebrew Package Updates

**Check what Homebrew packages have updates:**
```bash
# List outdated packages
brew outdated

# List outdated casks
brew outdated --cask

# Get detailed info about a specific package
brew info <package-name>
```

### Updating Packages

#### Updating All Packages

**Full upgrade (Nix + Homebrew):**
```bash
sysug
```
This runs `brew upgrade && brew cleanup` then `sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'`. To also refresh the flake inputs first: `sysup` then `sysug`, or run `nup` before `sysug`.

#### Updating Nix Packages Only

```bash
nup    # Update flake inputs
nug    # Rebuild and switch

# Or manually:
sudo nix flake update --flake /private/etc/nix-darwin
sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'
```

#### Updating Homebrew Packages Only

```bash
bu && bug

# Or manually:
brew update && brew upgrade && brew cleanup

# Single package/cask
brew upgrade <package-name>
brew upgrade --cask <cask-name>
```

#### Updating Individual Packages

**Nix packages:** Edit `packages.nix` (add/remove entries in the list), then run `nug` to rebuild.

**Homebrew packages:**
```bash
# Update individual formula
brew upgrade <package-name>

# Update individual cask
brew upgrade --cask <cask-name>
```

### Searching for Packages

#### Searching Nix Packages

**Online search (recommended):**
- Visit [search.nixos.org](https://search.nixos.org) for the most comprehensive search
- Filter by "Packages" and "nixpkgs unstable" for latest packages

**Command line search:**
```bash
# Search for packages containing a term
nix search nixpkgs <search-term>

# Search with more details
nix search nixpkgs <search-term> --json | jq

# Example: Search for Python packages
nix search nixpkgs python
```

**Advanced search examples:**
```bash
# Search for development tools
nix search nixpkgs "development.*tool"

# Search for specific language support
nix search nixpkgs golang
nix search nixpkgs rust

# Search for system utilities
nix search nixpkgs "system.*utility"
```

#### Searching Homebrew Packages

**Search formulas (CLI tools):**
```bash
# Search for a package
brew search <search-term>

# Search with descriptions
brew search --desc <search-term>

# Example searches
brew search editor
brew search --desc "password manager"
```

**Search casks (GUI applications):**
```bash
# Search for casks
brew search --cask <search-term>

# Search casks with descriptions
brew search --cask --desc <search-term>

# Example cask searches
brew search --cask editor
brew search --cask "development"
```

**Get detailed package information:**
```bash
# Get info about a formula
brew info <package-name>

# Get info about a cask
brew info --cask <cask-name>

# List all installed packages
brew list
brew list --cask
```

### Package Sources

#### Nix Packages
- **Source**: nixpkgs (unstable, from flake input)
- **Location**: `packages.nix` (function returning a list); used in `configuration.nix` as `environment.systemPackages = import ./packages.nix { inherit pkgs; };`
- **Examples**: `kubectl`, `helm`, `go`, `python3`, `docker-compose`
- **Update**: `nup` then `nug`, or `sysug`

#### Homebrew Formulas
- **Location**: `configuration.nix` → `homebrew.brews`
- **Examples**: `tfenv`, `kube-ps1`, `node@24`, `tofuenv`
- **Update**: `bu && bug` or `sysug`

#### Homebrew Casks
- **Location**: `configuration.nix` → `homebrew.casks`
- **Examples**: `postman`, `raycast`, `clipy`, `orbstack`, `keepassxc`, `rectangle`, `monokle`
- **Update**: `bug` or `sysug`

**Adding packages:**
- **Nix**: Add `pkgs.<name>` to the list in `packages.nix`, then run `nug`.
- **Homebrew formula**: Add to `homebrew.brews` in `configuration.nix`, then `nug`.
- **Homebrew cask**: Add to `homebrew.casks` in `configuration.nix`, then `nug`.

---

## Key Components

| File or directory | Purpose |
|-------------------|---------|
| **flake.nix** | Flake entry: inputs, `currentUser`, and darwin config wiring (imports `configuration.nix`, home-manager, `home-manager.nix`). |
| **configuration.nix** | macOS system config: `environment.systemPackages` (via `packages.nix`), homebrew (taps, brews, casks), nix settings, system defaults, users. |
| **packages.nix** | List of Nix system packages (single function `{ pkgs }: [ ... ]`). Edit here to add/remove Nix CLI tools. |
| **home-manager.nix** | Home Manager integration: `useGlobalPkgs`, `useUserPackages`, `extraSpecialArgs`, and `users.<currentUser> = import ./home`. |
| **home/default.nix** | Home Manager entry: imports (nvim, git, zsh, functions, bat, ssh, wezterm, oh-my-posh), `homeDirectory`, `stateVersion`. |
| **home/git.nix** | Git and delta configuration. |
| **home/zsh.nix** | Zsh: shell aliases and `initContent` (options, plugins, fzf, forgit, env). |
| **home/functions.nix** | Shell helpers written to `~/.functions` (kubectl, docker, port-forward, etc.). |
| **home/bat.nix** | Bat config (`~/.config/bat/config`). |
| **home/ssh.nix** | SSH config snippets (`~/.ssh/config_work`, `~/.ssh/config_personal`). |
| **home/wezterm.nix** | Deploys `home/wezterm/wezterm.lua` to `~/.config/wezterm/wezterm.lua`. |
| **home/oh-my-posh.nix** | Deploys `home/oh-my-posh/custom.yaml` to `~/.config/oh-my-posh/custom.yaml`. |
| **home/wezterm/wezterm.lua** | WezTerm Lua config (standalone file for editor support). |
| **home/oh-my-posh/custom.yaml** | Oh-My-Posh theme (YAML for editor formatting/linting). |
| **nvim.nix** | Neovim Home Manager config (at repo root). |
| **flake.lock** | Auto-generated lock file for flake inputs. |

---

## Terraform & tfenv

This setup includes [`tfenv`](https://github.com/tfutils/tfenv) (installed via Homebrew) for managing multiple Terraform versions easily.

### Installing Specific Terraform Versions

After running `darwin-rebuild switch --flake '.#darwin'` and ensuring Homebrew is installed:

```sh
# List available Terraform versions
$ tfenv list-remote

# Install required versions
$ tfenv install 0.13.7
$ tfenv install 0.15.5

# Set a global default (optional)
$ tfenv use 0.15.5

# Set a local version for a project
$ cd /path/to/your/terraform/project
$ tfenv use 0.13.7
```

You can switch between versions at any time using `tfenv use <version>`.

---

## Kubernetes Helper Functions

This configuration provides several helper functions and aliases to make working with Kubernetes easier. All kubectl commands use `kubecolor` for better readability.

### Quick Reference Aliases

- **k**: Short alias for `kubectl` (actually `kubecolor`)
- **ka**: Apply Kubernetes manifests (`kubecolor apply -f`)
- **kd**: Show differences before applying (`kubecolor diff -f`)
- **ktx**: Switch Kubernetes contexts (requires `kubectx`)
- **kns**: Switch Kubernetes namespaces (requires `kubens`)

**Usage Examples:**
```bash
# Quick kubectl commands
k get pods                    # Same as kubectl get pods but with colors
ka deployment.yaml           # Apply a deployment file
kd deployment.yaml           # Show what would change before applying
ktx staging                  # Switch to staging context
kns production               # Switch to production namespace
```

### Kubernetes Helper Functions

- **klp** `<namespace> <pod-name>`: Get logs from a specific pod
  ```bash
  klp default my-app-pod     # Get logs from my-app-pod in default namespace
  ```

- **ktp** `<namespace> <pod-name>`: Tail/follow logs from a specific pod
  ```bash
  ktp default my-app-pod     # Follow logs from my-app-pod in default namespace
  ```

- **kep** `<namespace> <pod-name>`: Execute into a pod with intelligent shell detection
  ```bash
  kep default my-app-pod     # Connect to my-app-pod in default namespace
  ```
  **Note:** This function automatically tries multiple shells (`/bin/bash`, `/bin/sh`, `bash`, `sh`) to find one that works in the container, making it compatible with any Linux container.

- **kgp** `[namespace] [pod-name-pattern]`: Get pods with flexible filtering
  ```bash
  kgp                        # Get all pods in all namespaces
  kgp default                # Get all pods in 'default' namespace  
  kgp default my-app         # Get pods containing 'my-app' in 'default' namespace
  ```

- **ktp** `<namespace> <pod-name>`: Tail logs from a specific pod
  ```bash
  ktp default my-app-pod     # Follow logs from my-app-pod in default namespace
  ```

---

## Docker Helper Functions

This configuration includes convenient Docker aliases and functions for container management.

### Docker Aliases

- **doc**: Alias for `docker`
- **dcl**: List all containers (`docker container ls -a`)
- **dil**: List all images (`docker image ls -a`)

**Usage examples:**
```bash
doc ps    # docker ps
dcl       # List all containers
dil       # List all images
```

### Docker Helper Functions

- **dec** `<container_name>`: Execute into a Docker container with intelligent shell detection
  ```bash
  dec my-container           # Connect to my-container with best available shell
  ```
  **Note:** This function automatically tries multiple shells (`/bin/bash`, `/bin/sh`, `bash`, `sh`) to find one that works in the container.

- **dps**: Display Docker containers with better formatting
  ```bash
  dps                        # Show containers in table format with names, images, status, ports
  ```

- **dclean**: Clean up Docker resources
  ```bash
  dclean                     # Remove unused containers, volumes, networks, and images
  ```

- **dlf** `<container_name>`: Follow container logs with timestamps
  ```bash
  dlf my-container           # Follow logs from my-container with timestamps
  ```

### Additional Helper Functions

- **pck** `<host> <port>`: Check if a port is open on a host
  ```bash
  pck google.com 80          # Check if port 80 is open on google.com
  pck localhost 8080         # Check if local service is running on port 8080
  ```

### Shell Features

- **Ultimate Oh-My-Posh Prompt**: Revolutionary command line experience with intelligent tooltips and performance monitoring
- **Smart Tooltips**: Git repository status appears when typing `git ` or `g `, AWS profile@region when typing `aws `, `terraform `, or `tf `
- **Full Path Display**: Complete directory visibility with `agnoster_full` style - no truncation
- **Kubernetes Safety**: Red ⎈ symbol with blue context text for cluster awareness
- **Performance Tracking**: Execution time display for commands >1ms in sky blue
- **Precise Timing**: 24-hour format with seconds for operation logging
- **Color Harmony**: Sophisticated purple/green/blue/pink palette optimized for readability
- **DevOps Optimized**: Perfect for kubectl, terraform, git, and AWS CLI workflows
- **kubectl/helm completions**: Tab completion for kubectl and helm commands (loaded asynchronously for performance)
- **fzf integration**: Enhanced history search with Ctrl+R
- **Enhanced history**: 100k command history with sharing between sessions
- **Performance optimized**: Lazy-loading completions and cached context checks for fast shell startup
- **Zsh Options**: Auto-cd, command correction, intelligent history, and extended globbing

---

## Terminal Key Bindings

This configuration includes editor-like key bindings for improved terminal navigation.

### Word Navigation
- **Option + Right Arrow**: Jump to next word
- **Option + Left Arrow**: Jump to previous word

### Word Deletion
- **Ctrl + W**: Delete previous word (standard zsh behavior)

**Note:** These key bindings work across all terminal applications (iTerm2, Alacritty, Terminal.app, etc.) and provide a consistent editor-like experience.

---

## Oh-My-Posh Prompt - The Ultimate DevOps Command Line Experience

This configuration features a meticulously crafted Oh-My-Posh setup that provides the perfect balance of information density, visual clarity, and performance optimization for DevOps workflows.

![Command Prompt Screenshot](https://github.com/user-attachments/assets/your-screenshot-url)

### 🎆 Main Prompt Layout

The main prompt displays essential information in an elegant, dash-separated format:
```
.-(~/very/long/path/to/project)----------(⎈ |spike.np.navi-tech.in:sentinelone)-2.1s--21:08:43-
`--> 
```

### 📊 Core Components

#### **Path Display** 📁
- **Full Path**: Uses `agnoster_full` style - no truncation, complete directory visibility
- **Format**: `.-(/complete/path/to/directory)`
- **Colors**: Light purple brackets (`#dda0dd`), bright green path text (`#00ff00`)
- **DevOps Benefit**: Always know exactly where you are for deployments and configurations

#### **Kubernetes Context** ⎈
- **Format**: `(⎈ |context:namespace)`
- **Colors**: Red helm symbol (`#ff6b6b`), blue context text (`#00bfff`)
- **Smart Display**: Shows current cluster and namespace for safe operations
- **Safety**: Red symbol draws attention to prevent wrong-cluster deployments

#### **Execution Time** ⏱️
- **Format**: `-2.1s-` or `-500ms-`
- **Color**: Sky blue (`#87ceeb`)
- **Threshold**: Shows for commands taking >1ms
- **DevOps Benefit**: Monitor performance of kubectl, terraform, and deployment scripts

#### **Time Display** 🕰️
- **Format**: `-HH:MM:SS-` (24-hour with seconds)
- **Color**: Light purple (`#dda0dd`)
- **Purpose**: Track when operations completed for logging and debugging

#### **Input Prompt** ➡️
- **Format**: `\`--> `
- **Color**: Light purple (`#dda0dd`)
- **Clean**: Minimal, consistent with theme

### 💫 Smart Tooltips System

Intelligent context-aware information that appears only when needed:

#### **Git Repository Tooltips** 🔀
**Triggers**: Type `git ` or `g ` (with space)
```
.-(~/project)----------(⎈ |k8s)-1.2s--21:08:43-      main  3 |  2
`--> git 
```
- **Branch Info**: Current branch name with git icon
- **Staging Area**: Files ready to commit with count
- **Working Changes**: Modified files with count
- **Color**: Soft pink (`#f8bbd9`) for gentle visibility
- **Performance**: Non-blocking, fast git status integration

#### **AWS Profile Tooltips** ☁️
**Triggers**: Type `aws `, `terraform `, or `tf ` (with space)
```
.-(~/infrastructure)----------(⎈ |prod-cluster)-3.4s--21:08:43-     ☁️ production@us-east-1
`--> terraform 
```
- **Profile & Region**: Shows active AWS profile and region
- **Multi-trigger**: Works with AWS CLI, Terraform, and tf alias
- **Color**: Orange (`#ffcc66`) matching AWS branding
- **Safety**: Verify environment before infrastructure changes

### 🎨 Sophisticated Color Palette

| Element | Color | Hex Code | Purpose |
|---------|-------|----------|----------|
| **Structure** | Light Purple | `#dda0dd` | Dashes, brackets, arrows - visual framework |
| **Path** | Bright Green | `#00ff00` | Directory location - high visibility |
| **Kubernetes** | Blue/Red | `#00bfff`/`#ff6b6b` | Context info with attention-grabbing symbol |
| **Execution Time** | Sky Blue | `#87ceeb` | Performance metrics - calm but noticeable |
| **Time** | Light Purple | `#dda0dd` | Timestamp - integrated with structure |
| **Git Tooltips** | Soft Pink | `#f8bbd9` | Repository status - gentle information |
| **AWS Tooltips** | Orange | `#ffcc66` | Cloud context - warm, AWS-themed |

### ⚡ Performance Optimizations

- **Execution Time**: 1ms threshold prevents noise from instant commands
- **Tooltip Mode**: `extend` - adds to prompt without replacing existing content
- **Git Status**: Cached and optimized for repository information
- **AWS Context**: Lightweight profile and region detection
- **Lazy Loading**: Tooltips appear only when command-specific triggers are used

### 🚀 DevOps Workflow Benefits

1. **Context Awareness**: Always know your cluster, namespace, AWS profile, and directory
2. **Performance Monitoring**: Track command execution times for optimization
3. **Safety Features**: Red Kubernetes symbol and AWS tooltips prevent wrong-environment operations
4. **Efficiency**: Full path display eliminates guesswork about current location
5. **Git Integration**: Instant repository status without running separate commands
6. **Clean Interface**: Information appears only when relevant (tooltips)
7. **Time Tracking**: Precise timestamps for operation logging

### 📝 Usage Examples

**Normal Operation**:
```
.-(~/microservices/api-gateway)----------(⎈ |production:default)-1.2s--21:08:43-
`--> kubectl get pods
```

**Git Work with Tooltip**:
```
.-(~/microservices/api-gateway)----------(⎈ |dev:feature)-45ms--21:09:15-      feature/auth  2 |  1
`--> git commit -m "Add authentication"
```

**Infrastructure Work with AWS Tooltip**:
```
.-(~/infrastructure/terraform/prod)----------(⎈ |prod-cluster)-3.4s--21:10:22-     ☁️ production@us-east-1
`--> terraform apply
```

### 🔧 Configuration Highlights

- **Config file**: `home/oh-my-posh/custom.yaml` (YAML; deployed to `~/.config/oh-my-posh/custom.yaml`).
- **Tooltip action**: `extend` – tooltips extend the prompt.
- **Path style**: `agnoster_full` in the path segment.
- **Execution threshold**: 1 ms (segment `executiontime`).
- **Git tooltip**: `tips: [git, g]`; `fetch_status` and `fetch_upstream_icon` in properties.
- **AWS tooltip**: `tips: [aws, terraform, tf]`; template shows `{{.Profile}}@{{.Region}}`.

### 🎯 Troubleshooting Oh-My-Posh Prompt

#### Common Issues and Solutions

**1. Prompt Not Appearing After Configuration**
```bash
nug              # Rebuild and switch
exec zsh         # Restart shell
```

**2. Tooltips Not Triggering**
- Type the command followed by a space (e.g. `git `, `aws `)
- Ensure oh-my-posh supports tooltips (v12.0+)
- Check YAML syntax in `home/oh-my-posh/custom.yaml`

**3. Kubernetes Context Not Showing**
```bash
# Check kubectl configuration
kubectl config current-context
kubectl config get-contexts

# If no context is set:
kubectl config use-context <your-context>
```

**4. AWS Profile Not Displaying in Tooltips**
```bash
# Check AWS configuration
aws configure list
echo $AWS_PROFILE

# Set profile if needed:
export AWS_PROFILE=your-profile
```

**5. Git Status Not Updating**
```bash
# Ensure you're in a git repository
git status

# Check git configuration
git config --list
```

**6. Colors Not Displaying Correctly**
- Verify terminal supports 256 colors or true color
- Check terminal color scheme compatibility
- Test: `oh-my-posh print primary --config ~/.config/oh-my-posh/custom.yaml`

**7. Performance Issues**
- Increase execution time threshold in `home/oh-my-posh/custom.yaml`
- Disable git `fetch_status` for large repos
- Use `oh-my-posh debug --config ~/.config/oh-my-posh/custom.yaml` to find slow segments

#### Debug commands

```bash
# Test prompt
oh-my-posh print primary --config ~/.config/oh-my-posh/custom.yaml

# Debug segments
oh-my-posh debug --config ~/.config/oh-my-posh/custom.yaml

# Version
oh-my-posh version
```

### ⚙️ Customizing Your Prompt

Edit **`home/oh-my-posh/custom.yaml`** (YAML). It is deployed to `~/.config/oh-my-posh/custom.yaml` by `home/oh-my-posh.nix`.

- **Add segments**: Add new entries under `blocks` (see [Oh-My-Posh docs](https://ohmyposh.dev/docs/)).
- **Change colors**: Set `foreground` (hex) on the segment.
- **Tooltips**: Edit the `tooltips` list; triggers are in `tips` (e.g. `git`, `g`, `aws`, `terraform`, `tf`).
- **Execution time**: Under the segment with `type: executiontime`, set `properties.threshold` (e.g. `500` for 500 ms).
- **Git tooltip**: Under the `type: git` tooltip, set `fetch_status: false` for large repos if needed.

After editing, run `nug` and restart the shell (or `exec zsh`).

---

## Neovim Editor

A comprehensive Neovim configuration is included with language servers, modern plugins, and an intuitive setup.

### Key Features

- **Theme**: Tokyo Night dark theme with night style (darkest variant)
- **Status Bar**: Lualine with Tokyo Night theme, git integration and diagnostics
- **File Explorer**: NvimTree with git status indicators
- **Fuzzy Finder**: Telescope for fast file/content searching
- **Syntax Highlighting**: Treesitter with support for many languages
- **Autocompletion**: nvim-cmp with LSP integration
- **Git Integration**: Gitsigns showing changes in the gutter
- **Comments**: Easy commenting with Comment.nvim
- **Key Helper**: Which-key shows available keybindings

### Important Keybindings

**Leader key is set to Space**

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<Space>ff` | Find Files | Search for files in project |
| `<Space>fg` | Live Grep | Search content in files |
| `<Space>fb` | Find Buffers | Switch between open files |
| `<Space>e` | Toggle Explorer | Show/hide file tree |
| `<Space>w` | Save | Save current file |
| `<Space>q` | Quit | Close current window |
| `gd` | Go to Definition | Jump to symbol definition |
| `K` | Hover | Show documentation |
| `gr` | References | Find all references |
| `<Space>rn` | Rename | Rename symbol |
| `<Space>ca` | Code Action | Show available code actions |
| `<Space>lf` | Format | Format current file |
| `[d` / `]d` | Diagnostics | Navigate errors/warnings |
| `gcc` | Comment Line | Toggle line comment |
| `gc` (visual) | Comment Selection | Toggle comment on selection |

**Window Navigation:**
- `Ctrl+h/j/k/l` - Navigate between windows
- `Ctrl+Arrow` - Resize windows

### Language Server Support

The configuration includes language servers and formatters for:

| Language | LSP Server | Formatter | Features |
|----------|------------|-----------|----------|
| **Python** | Pyright | Black | Type checking, auto-import, refactoring |
| **Go** | gopls | gofumpt | Auto-import, staticcheck, unused params detection |
| **Bash/Shell** | bash-language-server | shellcheck | Linting, completion |
| **Lua** | lua-language-server | stylua | Neovim API support |
| **YAML** | yaml-language-server | prettier | Schema validation |
| **JSON** | vscode-json-languageserver | prettier | Schema validation |
| **JavaScript/TypeScript** | via Treesitter | prettier | Syntax highlighting |
| **Markdown** | via Treesitter | prettier | Syntax highlighting |

All language servers provide:
- Intelligent code completion
- Go to definition/references
- Hover documentation
- Diagnostic errors/warnings
- Code actions and quick fixes
- Symbol renaming

To use Neovim after applying the configuration:
```bash
nug        # Rebuild if you changed nvim.nix
nvim       # Or: vim (alias)
```

---

## Included Packages

**Nix packages** are listed in **`packages.nix`**; **Homebrew** formulae and casks are in **`configuration.nix`**.

### Nix (packages.nix)

- **Development**: `go`, `python3`, `git`, `delta`, `difftastic`
- **Cloud / infra**: `awscli`, `oci-cli`, `ansible`, `packer`, `sops`, `age`, `pulumi-bin`
- **Kubernetes / containers**: `kubectl`, `kubernetes-helm`, `minikube`, `kops`, `k9s`, `kubectx`, `stern`, `docker-compose`, `dive`, `kubecolor`
- **Utilities**: `bat`, `eza`, `tree`, `rsync`, `ncdu`, `dust`, `fzf`, `ripgrep`, `htop`, `prometheus`, `fastfetch`, `tmux`, `jq`, `yq-go`, `wget`, `curlie`, `postgresql`, `shfmt`, `envsubst`, `gojsontoyaml`, `pwgen`, `cassandra`, `kafkactl`
- **Shell / prompt**: `oh-my-posh`, `zsh-fast-syntax-highlighting`, `zsh-autosuggestions`, `zsh-fzf-tab`, `zoxide`, `zsh-forgit`, `wezterm`
- **Neovim LSP/formatters**: `pyright`, `gopls`, `bash-language-server`, `lua-language-server`, `yaml-language-server`, `vscode-langservers-extracted`, `black`, `gofumpt`, `shellcheck`, `stylua`, `prettier`

### Homebrew (configuration.nix)

- **Brews**: `tfenv`, `kube-ps1`, `node@24`, `tofuenv`
- **Casks**: Postman, Raycast, Clipy, OrbStack, KeePassXC, AutoRaise, Rectangle, Monokle

---

## Customization

- **Username**: Set `currentUser` in the `let` block in `flake.nix` to your macOS username.
- **Nix packages**: Edit the list in `packages.nix`, then run `nug`.
- **Homebrew formulae/casks**: Edit `homebrew.brews` and `homebrew.casks` in `configuration.nix`, then run `nug`.
- **Shell aliases and rc**: `home/zsh.nix`.
- **Oh-My-Posh theme**: `home/oh-my-posh/custom.yaml`.
- **WezTerm**: `home/wezterm/wezterm.lua`.
- **Git config**: `home/git.nix`. **Kubernetes/Docker shell helpers**: `home/functions.nix`.

---

## Troubleshooting

- If you encounter issues with missing packages or errors during the build, ensure your Nix and nix-darwin installations are up to date.
- For Homebrew casks, make sure Homebrew is installed manually (not managed by Nix).

---

## Nix language basics (Python comparison)

If you know Python and want to read `flake.nix`, `packages.nix`, and Home Manager modules without learning Nix from scratch first, see **[docs/nix-language-basics-python.md](docs/nix-language-basics-python.md)**. It compares bindings, functions, conditionals, attrsets, and flake inputs/outputs to familiar Python ideas.

---

## References
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
