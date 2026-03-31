# System packages installed via nix-darwin.
# Edit this list and rebuild to add/remove packages.
{ pkgs }: [
  pkgs.fastfetch
  pkgs.git
  pkgs.htop
  pkgs.tmux
  pkgs.bat
  pkgs.eza
  pkgs.go
  pkgs.python315
  pkgs.lua
  pkgs.kubectl
  pkgs.kubernetes-helm
  pkgs.fzf
  pkgs.ripgrep
  pkgs.yq-go
  pkgs.jq
  pkgs.awscli2
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
  pkgs.kubecolor
  pkgs.curlie
  pkgs.sops
  pkgs.age
  pkgs.packer
  pkgs.shfmt
  pkgs.envsubst
  pkgs.gojsontoyaml
  pkgs.pwgen
  pkgs.kafkactl
  pkgs.oh-my-posh
  pkgs.zsh-fast-syntax-highlighting
  pkgs.zsh-autosuggestions
  pkgs.zsh-fzf-tab
  pkgs.zoxide
  pkgs.zsh-forgit
  pkgs.wezterm
  pkgs.pulumi-bin
  pkgs.k9s
  pkgs.kubebuilder

  # Enhanced git diff tools
  pkgs.delta
  pkgs.difftastic

  # Language servers for Neovim
  pkgs.pyright
  pkgs.gopls
  pkgs.bash-language-server
  pkgs.lua-language-server
  pkgs.yaml-language-server
  pkgs.vscode-langservers-extracted

  # Formatters and linters
  pkgs.black
  pkgs.gofumpt
  pkgs.shellcheck
  pkgs.stylua
  pkgs.nodePackages.prettier
]
