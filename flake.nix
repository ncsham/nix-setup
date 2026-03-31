{
  description = "NCShams Default Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    # Resolved at eval time from the environment; requires --impure on darwin-rebuild
    # (or any `nix` command that evaluates this flake). Shell expands USER before sudo.
    currentUser =
      let
        u = builtins.getEnv "USER";
      in
      if u != "" then
        u
      else
        throw ''
          flake.nix: USER is empty (pure flake evaluation). Rebuild with --impure.
          In zsh you must quote the flake attribute — # starts a comment if unquoted:
            sudo /usr/bin/env USER="$USER" darwin-rebuild switch --impure --flake '/private/etc/nix-darwin#darwin'
        '';
  in
  {
    darwinConfigurations."darwin" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit currentUser self; };
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        ./home-manager.nix
      ];
    };
  };
}
