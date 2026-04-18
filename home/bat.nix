# Bat (cat replacement) configuration.
{ ... }:
{
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "numbers,changes";
      paging = "never";
    };
  };
}
