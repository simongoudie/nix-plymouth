{
  description = "Animated Plymouth boot screen theme for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "plymouth-nix-animated";
            version = "1.0.0";

            src = ./.;

            buildInputs = [ pkgs.plymouth ];

            installPhase = ''
              mkdir -p $out/share/plymouth/themes/nix-animated

              # Copy all theme files
              cp nix-animated.plymouth $out/share/plymouth/themes/nix-animated/
              cp nix-animated.script $out/share/plymouth/themes/nix-animated/
              cp progress-*.png $out/share/plymouth/themes/nix-animated/

              # Fix paths in .plymouth file to use $out
              sed -i "s|/run/current-system/sw|$out|g" \
                $out/share/plymouth/themes/nix-animated/nix-animated.plymouth
            '';

            meta = with pkgs.lib; {
              description = "Animated Plymouth boot screen theme";
              license = licenses.mit;
              platforms = platforms.linux;
              maintainers = [ ];
            };
          };
        });

      # NixOS module for easy integration
      nixosModules.default = { config, lib, pkgs, ... }: {
        options.boot.plymouth.themes.nix-animated = {
          enable = lib.mkEnableOption "NixOS animated Plymouth theme";
        };

        config = lib.mkIf config.boot.plymouth.themes.nix-animated.enable {
          boot.plymouth = {
            enable = true;
            theme = "nix-animated";
            themePackages = [ self.packages.${pkgs.system}.default ];
          };
        };
      };
    };
}
