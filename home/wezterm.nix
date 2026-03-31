# WezTerm config: deploy Lua file to ~/.config/wezterm/wezterm.lua.
{ ... }:
{
  home.file.".config/wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
}
