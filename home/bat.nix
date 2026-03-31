# Bat (cat replacement) configuration.
{ ... }:
{
  home.file.".config/bat/config".text = ''
    --theme=Dracula
    --style=numbers,changes
  '';
}
