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

## Getting Started

### Prerequisites
- [Nix](https://nixos.org/download.html) (with Flakes enabled)
- [nix-darwin](https://github.com/LnL7/nix-darwin#installation)
- (Optional) [Homebrew](https://brew.sh/) for additional casks

### Installation

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url> ~/nix-darwin
   cd ~/nix-darwin
   ```

2. **Review and edit `flake.nix`:**
   - Adjust the `system.primaryUser`, `users.users.<username>`, and other fields as needed for your setup.

3. **Switch to the new configuration:**
   ```sh
   darwin-rebuild switch --flake '.#darwin'
   ```

4. **(Optional) Install Homebrew apps:**
   - If you want to use Homebrew casks, ensure Homebrew is installed manually (see comments in `flake.nix`).

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

This configuration includes several custom Kubernetes functions for easier cluster management:

### Available Functions

- **`kgp`** - kubectl get pods
  ```sh
  kgp                    # Get all pods in all namespaces
  kgp <namespace>        # Get pods in specific namespace
  kgp <namespace> <pattern>  # Get pods matching pattern in namespace
  ```

- **`klp`** - kubectl logs pods
  ```sh
  klp <namespace> <pod-name>  # Get logs from a pod
  ```

- **`ktp`** - kubectl tail logs of pods
  ```sh
  ktp <namespace> <pod-name>  # Follow/tail logs from a pod
  ```

- **`kep`** - kubectl exec pod
  ```sh
  kep <namespace> <pod-name>  # Execute bash shell in a pod
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
