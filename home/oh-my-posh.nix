# Oh My Posh prompt theme: deploy custom.yaml to ~/.config/oh-my-posh/
{ ... }:
{
  home.file.".config/oh-my-posh/custom.yaml".source = ./oh-my-posh/custom.yaml;
}
