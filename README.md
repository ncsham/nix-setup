# Nix Darwin Flakes

This project provides a comprehensive [Nix Flake](https://nixos.wiki/wiki/Flakes) setup for managing and provisioning a macOS system using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). It is tailored for Apple Silicon (aarch64-darwin) and is designed to make your system configuration reproducible, declarative, and easily portable.

---

## Features

- **Reproducible macOS Configuration**: All system settings, packages, and user preferences are managed from a single `flake.nix` file.
- **Nix-Darwin Integration**: Leverage the power of Nix to manage macOS like NixOS.
- **Home-Manager**: Manage user-level packages and dotfiles declaratively.
- **Comprehensive Package Set**: Includes development tools (`go`, `python3`, `awscli`, `opentofu`), Kubernetes tools (`kubectl`, `helm`, `minikube`, `kops`), system utilities (`bat`, `eza`, `fzf`, `ripgrep`, `htop`, `tree`), and more.
- **Kubernetes Integration**: Pre-configured with kubectl/helm completions and custom Kubernetes helper functions.
- **Enhanced Shell Experience**: ZSH configuration with fzf integration, history management, and custom prompt with kube-ps1.
- **Homebrew Support**: GUI apps and additional tools via Homebrew (Lens, Postman, Raycast, etc.).
- **Apple Silicon Ready**: Configured for `aarch64-darwin` (Apple Silicon/M1/M2).

---

## Table of Contents

- [Initial Setup from Scratch](#initial-setup-from-scratch)
  - [Step 1: Install the Determinate Nix Distribution](#step-1-install-the-determinate-nix-distribution)
  - [Step 2: Create the Base Configuration Directory](#step-2-create-the-base-configuration-directory)
  - [Step 3: Initialize with Unstable Nixpkgs](#step-3-initialize-with-unstable-nixpkgs)
  - [Step 4: Initial nix-darwin Installation](#step-4-initial-nix-darwin-installation)
  - [Step 5: Install Homebrew](#step-5-install-homebrew-optional-but-recommended)
  - [Step 6: Replace with This Configuration](#step-6-replace-with-this-configuration)
  - [Step 7: Verify Installation](#step-7-verify-installation)
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
- [PDF Processing](#pdf-processing)
- [Terminal Key Bindings](#terminal-key-bindings)
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

---

## Initial Setup from Scratch

If you're setting up nix-darwin for the first time on a fresh macOS system, follow these steps:

### Step 1: Install the Determinate Nix Distribution
The Determinate Nix installer provides a more reliable and feature-complete Nix installation:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

### Step 2: Create the Base Configuration Directory
Set up the nix-darwin configuration directory with proper permissions:
```bash
sudo mkdir -p /etc/nix-darwin
sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
cd /etc/nix-darwin
```

### Step 3: Initialize with Unstable Nixpkgs
Create a basic flake configuration and customize it for your system:
```bash
# Initialize the flake template
nix flake init -t nix-darwin/master

# Replace 'simple' with your actual hostname (optional - you can use 'darwin' for generic)
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
# OR use generic configuration:
sed -i '' "s/simple/darwin/" flake.nix
```

### Step 4: Initial nix-darwin Installation
Install nix-darwin for the first time:
```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake '.#darwin'
```

### Step 5: Install Homebrew (Optional but Recommended)
Homebrew is needed for GUI applications and some packages not available in nixpkgs:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 6: Replace with This Configuration
Now you can replace the basic template with this comprehensive configuration:
```bash
# Clone this repository
git clone https://github.com/ncsham/nix-setup.git /tmp/nix-setup

# Backup the original files
cp flake.nix flake.nix.bak
cp flake.lock flake.lock.bak 2>/dev/null || true

# Copy the comprehensive configuration
cp /tmp/nix-setup/flake.nix .
cp /tmp/nix-setup/flake.lock .
cp /tmp/nix-setup/README.md .

# Apply the new configuration
sudo darwin-rebuild switch --flake '.#darwin'
```

### Step 7: Verify Installation
After the rebuild completes, start a new shell session and verify:
```bash
# Check if the 'nu' alias works
nu

# Verify Kubernetes functions
kgp --help 2>/dev/null || echo "kubectl not configured yet"

# Check if Homebrew packages are installed
brew list | grep -E "tfenv|kube-ps1"
```

---

## Getting Started

*If you're setting up nix-darwin from scratch, see the [Initial Setup from Scratch](#initial-setup-from-scratch) section above.*

### For Existing nix-darwin Users

If you already have nix-darwin installed and want to use this configuration:

1. **Clone this repository:**
   ```bash
   git clone https://github.com/ncsham/nix-setup.git /tmp/nix-setup
   cd /etc/nix-darwin  # or wherever your nix-darwin config is located
   ```

2. **Backup your current configuration:**
   ```bash
   cp flake.nix flake.nix.bak
   cp flake.lock flake.lock.bak 2>/dev/null || true
   ```

3. **Copy the new configuration:**
   ```bash
   cp /tmp/nix-setup/flake.nix .
   cp /tmp/nix-setup/flake.lock .
   ```

4. **Review and customize the configuration:**
   - Edit `flake.nix` to adjust usernames, paths, and package selections as needed
   - Update the `currentUser` variable on line 14 to match your username

5. **Apply the new configuration:**
   ```bash
   sudo darwin-rebuild switch --flake '.#darwin'
   ```

### Quick Commands After Setup
- **Update system**: Use `nu` alias from anywhere
- **Manage Terraform versions**: `tfenv list-remote`, `tfenv install <version>`, `tfenv use <version>`
- **Kubernetes shortcuts**: `kgp`, `klp`, `ktp`, `kep` (see [Kubernetes Helper Functions](#kubernetes-helper-functions))

---

## Package Management

This section provides comprehensive guidance on managing packages in your nix-darwin setup, including both Nix packages and Homebrew packages.

### Quick Update Commands

The configuration includes convenient aliases for keeping your system up to date:

#### Available Update Aliases

- **`nix-update`**: Updates Nix flake and rebuilds darwin configuration
- **`brew-update`**: Updates all Homebrew packages and performs cleanup
- **`update-all`**: Comprehensive update that handles both Nix and Homebrew with progress messages
- **`nu`**: Quick rebuild of current configuration (no package updates)

**Usage Examples:**
```bash
# Update only Nix packages
nix-update

# Update only Homebrew packages
brew-update

# Update everything (recommended)
update-all

# Quick rebuild without updates
nu
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

**Recommended approach - Update everything:**
```bash
update-all
```

This command will:
1. Update Nix flake inputs (nixpkgs, etc.)
2. Rebuild and switch to new darwin configuration
3. Update all Homebrew packages (both formulas and casks)
4. Clean up old Homebrew versions
5. Provide progress feedback throughout

#### Updating Nix Packages Only

```bash
# Update and apply Nix configuration
nix-update

# Or manually step by step:
sudo nix flake update /private/etc/nix-darwin
sudo darwin-rebuild switch --flake '/private/etc/nix-darwin#darwin'
```

#### Updating Homebrew Packages Only

```bash
# Update all Homebrew packages
brew-update

# Or manually:
brew update && brew upgrade && brew upgrade --cask && brew cleanup

# Update specific package
brew upgrade <package-name>

# Update specific cask
brew upgrade --cask <cask-name>
```

#### Updating Individual Packages

**For Nix packages:** Individual Nix package updates require editing `flake.nix` and rebuilding:
1. Edit `/private/etc/nix-darwin/flake.nix`
2. Update the package version or add/remove packages in `environment.systemPackages`
3. Run `nu` to rebuild

**For Homebrew packages:**
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

#### Nix Packages (`environment.systemPackages`)
- **Source**: nixpkgs-unstable channel
- **Location in config**: `flake.nix` → `environment.systemPackages` array
- **Type**: Primarily CLI tools and system libraries
- **Examples**: `kubectl`, `helm`, `go`, `python3`, `docker-compose`
- **Update method**: `nix-update` or `update-all`

#### Homebrew Formulas (`homebrew.brews`)
- **Source**: Homebrew formulae
- **Location in config**: `flake.nix` → `homebrew.brews` array
- **Type**: CLI tools not available in Nix or with better Homebrew support
- **Examples**: `tfenv`, `kube-ps1`, `node@24`
- **Update method**: `brew-update` or `update-all`

#### Homebrew Casks (`homebrew.casks`)
- **Source**: Homebrew casks
- **Location in config**: `flake.nix` → `homebrew.casks` array
- **Type**: GUI applications for macOS
- **Examples**: `postman`, `raycast`, `keepassxc`, `rectangle`
- **Update method**: `brew-update` or `update-all`

**Package Priority Guidelines:**
1. **Prefer Nix packages** for reproducibility and declarative management
2. **Use Homebrew formulas** when Nix packages are outdated or unavailable
3. **Use Homebrew casks** for all GUI applications (required for macOS apps)

**Adding New Packages:**
1. Search for the package using methods above
2. Add to appropriate section in `flake.nix`:
   - Nix: `environment.systemPackages = [ pkgs.<package-name> ];`
   - Homebrew formula: `homebrew.brews = [ "<package-name>" ];`
   - Homebrew cask: `homebrew.casks = [ "<package-name>" ];`
3. Run `nu` to apply changes

---

## Key Components

- **flake.nix**: Main configuration file containing all system, user, and package definitions.
- **flake.lock**: Auto-generated lock file to pin dependency versions.

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

- **doc**: Short alias for `docker`
- **dcl**: List all Docker containers (`docker container ls -a`)
- **dil**: List all Docker images (`docker image ls -a`)
- **spdf**: Start Stirling PDF server (`stirling-pdf`)

**Usage Examples:**
```bash
doc ps                      # Same as docker ps
dcl                         # List all containers (running and stopped)
dil                         # List all images
spdf                        # Start Stirling PDF web server
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

- **Kube-PS1**: Current Kubernetes context and namespace displayed in prompt
- **AWS Profile Display**: Current AWS profile shown in prompt (☁|profile-name)
- **kubectl/helm completions**: Tab completion for kubectl and helm commands (loaded asynchronously for performance)
- **fzf integration**: Enhanced history search with Ctrl+R
- **Enhanced history**: 100k command history with sharing between sessions
- **Performance optimized**: Lazy-loading completions and cached context checks for fast shell startup

---

## PDF Processing

This configuration includes Stirling PDF, a self-hosted web application for PDF manipulation.

### Starting Stirling PDF

After running `nu` (darwin-rebuild), you can start Stirling PDF:

```bash
# Using the alias (recommended)
spdf

# Or directly
stirling-pdf
```

This starts a web server on `http://localhost:8080` where you can:
- Merge, split, and rotate PDFs
- Convert between formats
- Add/remove pages
- OCR scanned documents
- Add watermarks and signatures
- Compress PDFs
- And much more

**Note:** Stirling PDF runs locally and doesn't send your documents to external servers, ensuring privacy.

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

## Neovim Editor

A comprehensive Neovim configuration is included with language servers, modern plugins, and an intuitive setup.

### Key Features

- **Theme**: Gruvbox dark theme for comfortable coding
- **Status Bar**: Lualine with git integration and diagnostics
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
# Rebuild the configuration
nu

# Start Neovim
nvim

# Or use the aliases
vim   # Also opens Neovim
vi    # Also opens Neovim
```

---

## Included Packages

### Development Tools
- **Languages**: `go`, `python3`
- **Editors**: `neovim`
- **Version Control**: `git`

### Cloud & Infrastructure
- **AWS**: `awscli`
- **Oracle Cloud**: `oci-cli`
- **Terraform**: `opentofu` (OpenTofu)
- **Configuration Management**: `ansible`
- **Image Building**: `packer`
- **Secrets Management**: `sops`

### Kubernetes & Container Tools
- **Core**: `kubectl`, `kubernetes-helm`, `minikube`
- **Management**: `kops`, `k9s`, `kubectx`, `stern`
- **Container**: `docker-compose`, `dive` (Docker image analyzer)
- **Utilities**: `kubecolor` (colorized kubectl output)

### System Utilities
- **File Management**: `bat`, `eza`, `tree`, `rsync`, `ncdu`, `dust` (disk usage analyzer)
- **Search**: `fzf`, `ripgrep`
- **System Monitoring**: `htop`, `prometheus`, `fastfetch`
- **Terminal**: `tmux`
- **Data Processing**: `jq`, `yq-go`, `jsonnet`, `jsonnet-bundler`
- **Network**: `wget`, `curlie` (modern curl alternative)
- **Database**: `mycli`, `postgresql`
- **Document Processing**: `stirling-pdf` (self-hosted PDF manipulation)
- **Infrastructure**: `packer` (image building), `sops` (secrets management)
- **Shell Tools**: `shfmt` (shell formatter), `envsubst` (environment variable substitution)
- **Data Conversion**: `gojsontoyaml` (JSON to YAML converter)

### Homebrew Packages
- **Development**: Lens (Kubernetes IDE), Postman (API testing)
- **Productivity**: Raycast (launcher), Clipy (clipboard), Rectangle (window management)
- **Security**: KeePassXC (password manager)
- **Infrastructure**: OrbStack (containers), AutoRaise
- **CLI Tools**: `tfenv` (Terraform version manager), `kube-ps1` (Kubernetes prompt)

---

## Customization

- **Add or remove packages**: Edit the `environment.systemPackages` list in `flake.nix`.
- **Enable/disable Homebrew casks**: Edit the `homebrew.casks` list.
- **Change username**: Update the `currentUser` variable on line 14 of `flake.nix` to match your system username.

---

## Troubleshooting

- If you encounter issues with missing packages or errors during the build, ensure your Nix and nix-darwin installations are up to date.
- For Homebrew casks, make sure Homebrew is installed manually (not managed by Nix).

---

## References
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)

---

## License
MIT

---

*Last updated on 2025-08-28. For questions or improvements, please open an issue or PR.*
