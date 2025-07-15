# Nix Darwin Flakes

This project provides a comprehensive [Nix Flake](https://nixos.wiki/wiki/Flakes) setup for managing and provisioning a macOS system using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). It is tailored for Apple Silicon (aarch64-darwin) and is designed to make your system configuration reproducible, declarative, and easily portable.

---

## Features

- **Reproducible macOS Configuration**: All system settings, packages, and user preferences are managed from a single `flake.nix` file.
- **Nix-Darwin Integration**: Leverage the power of Nix to manage macOS like NixOS.
- **Home-Manager**: Manage user-level packages and dotfiles declaratively.
- **Preconfigured Packages**: Includes a curated set of CLI tools (e.g., `neovim`, `git`, `htop`, `tmux`, `fzf`, `ripgrep`, etc.).
- **Homebrew Support**: Optionally install GUI apps and other tools via Homebrew casks.
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
   darwin-rebuild switch --flake .
   ```

4. **(Optional) Install Homebrew apps:**
   - If you want to use Homebrew casks, ensure Homebrew is installed manually (see comments in `flake.nix`).

---

## Key Components

- **flake.nix**: Main configuration file containing all system, user, and package definitions.
- **flake.lock**: Auto-generated lock file to pin dependency versions.

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
