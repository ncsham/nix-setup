# Zsh: aliases and initContent (options, plugins, fzf, forgit, env).
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      ls = "eza";
      ll = "ls -lah";
      cat = "bat";
      grep = "rg";

      # Nix package management (nug/nugp/sysug* are functions — see initContent)
      nup = "sudo nix flake update --flake /private/etc/nix-darwin";

      # Homebrew package management
      bu = "brew update";
      bug = "brew upgrade && brew cleanup";

      # Combined system updates
      sysup = "brew update && sudo nix flake update --flake /private/etc/nix-darwin";

      g = "git";
      gad = "git add";
      gdi = "git diff";
      gs = "git status";
      gc = "git commit -m";
      gpu = "git push origin";
      gp = "git pull";
      gcm = "git checkout master";
      gcbn = "git checkout -b";
      gd = "git diff";
      gds = "git diff --staged";
      gdss = "git diff --staged --stat";
      gdd = "git -c core.pager=delta diff";
      gdds = "git -c core.pager=delta diff --staged";
      gdsbs = "git -c core.pager=delta -c delta.side-by-side=true diff";
      gdw = "git diff --word-diff";
      gdiff = "difft";

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
      arc = "open -a Arc";
      keepassxc = "open -a KeePassXC";
      postman = "open -a Postman";
      orbstack = "open -a OrbStack";
      clipy = "open -a Clipy";
      code = "open -a Cursor";
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

      # For List of Zsh Options: https://zsh.sourceforge.io/Doc/Release/Options.html 
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_SILENT
      setopt PUSHD_IGNORE_DUPS
      setopt CORRECT
      setopt CORRECT_ALL
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_REDUCE_BLANKS
      setopt GLOB_DOTS
      setopt EXTENDED_GLOB
      setopt NO_BEEP
      setopt INTERACTIVE_COMMENTS
      setopt MULTIOS
      setopt PROMPT_SUBST

      source ~/.functions
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/custom.yaml)"

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags '--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9' '--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9' '--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6' '--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4' '--height=50%' '--layout=reverse' '--border'

      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      eval "$(zoxide init zsh)"

      export FORGIT_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height=80% --preview-window=right:60%"
      export FORGIT_LOG_GRAPH_ENABLE=true
      export FORGIT_COPY_CMD='pbcopy'
      source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh

      if [[ -f ~/.awsp && -s ~/.awsp ]]; then
        export AWS_PROFILE=$(cat ~/.awsp)
      fi

      {
        if command -v kubectl >/dev/null 2>&1; then
          source <(kubectl completion zsh) 2>/dev/null
        fi
        if command -v helm >/dev/null 2>&1; then
          source <(helm completion zsh) 2>/dev/null
        fi
      } &!

      source ${pkgs.fzf}/share/fzf/key-bindings.zsh 2>/dev/null
      source ${pkgs.fzf}/share/fzf/completion.zsh 2>/dev/null

      export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height 50% --layout=reverse --border'
      export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'

      export HISTSIZE=10000
      export SAVEHIST=100000
      export SHARE_HISTORY=true
      export AWS_REGION=ap-south-1
    '';
  };
}
