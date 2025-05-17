{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {

        # nix develop .#hello or nix shell .#hello
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.texlive.combined.scheme-medium
          ];
        };
        
        # nix develop or nix shell
        devShell = self.devShells.${system}.default;
      });
}
