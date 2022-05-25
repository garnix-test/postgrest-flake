{
  description = "REST API for any Postgres database";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  inputs.postgrest = {
    url = "github:PostgREST/postgrest";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    postgrest,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    defaultPackage = forAllSystems (system: let
      compiler = "ghc8107";
      overlay = import (postgrest + "/nix/overlays/haskell-packages.nix") {inherit compiler;};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay];
      };
      haskellLib = pkgs.haskell.lib.compose;
    in
      haskellLib.dontCheck (
        pkgs.haskell.packages.${compiler}.callCabal2nix "postgrest" postgrest {}
      ));
  };
}
