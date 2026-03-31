# Home Manager integration: options and user config entry point.
{ config, currentUser, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit currentUser; };
  home-manager.users.${currentUser} = import ./home;
}
