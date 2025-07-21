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
- [Key Components](#key-components)
- [Terraform & tfenv](#terraform--tfenv)
  - [Installing Specific Terraform Versions](#installing-specific-terraform-versions)
- [Kubernetes Helper Functions](#kubernetes-helper-functions)
  - [Available Functions](#available-functions)
  - [Shell Features](#shell-features)
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
   - The configuration uses `nitheeshchandrashamanthu` as the username - change this to your username

5. **Apply the new configuration:**
   ```bash
   sudo darwin-rebuild switch --flake '.#darwin'
   ```

### Quick Commands After Setup
- **Update system**: Use `nu` alias from anywhere
- **Manage Terraform versions**: `tfenv list-remote`, `tfenv install <version>`, `tfenv use <version>`
- **Kubernetes shortcuts**: `kgp`, `klp`, `ktp`, `kep` (see [Kubernetes Helper Functions](#kubernetes-helper-functions))

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

**Usage Examples:**
```bash
# Quick kubectl commands
k get pods                    # Same as kubectl get pods but with colors
ka deployment.yaml           # Apply a deployment file
kd deployment.yaml           # Show what would change before applying
ktx staging                  # Switch to staging context
```

### Helper Functions

- **klp** `<namespace> <pod-name>`: Get logs from a specific pod
  ```bash
  klp default my-app-pod     # Get logs from my-app-pod in default namespace
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

### Shell Features

- **Kube-PS1**: Current Kubernetes context and namespace displayed in prompt
- **kubectl/helm completions**: Tab completion for kubectl and helm commands
- **fzf integration**: Enhanced history search with Ctrl+R
- **Enhanced history**: 100k command history with sharing between sessions

---

## Included Packages

### Development Tools
- **Languages**: `go`, `python3`
- **Editors**: `neovim`
- **Version Control**: `git`

### Cloud & Infrastructure
- **AWS**: `awscli`
- **Terraform**: `opentofu` (OpenTofu)
- **Configuration Management**: `ansible`

### Kubernetes & Container Tools
- **Core**: `kubectl`, `kubernetes-helm`, `minikube`
- **Management**: `kops`
- **Container**: `docker-compose`

### System Utilities
- **File Management**: `bat`, `eza`, `tree`, `rsync`, `ncdu`
- **Search**: `fzf`, `ripgrep`
- **System Monitoring**: `htop`, `prometheus`
- **Terminal**: `tmux`
- **Data Processing**: `jq`, `yq-go`
- **Network**: `wget`
- **Database**: `mycli`, `postgresql`

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
- **User settings**: Adjust the `users.users.<username>` and `system.primaryUser` fields.

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

*Generated on 2025-07-15. For questions or improvements, please open an issue or PR.*
