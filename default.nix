{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
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
}
