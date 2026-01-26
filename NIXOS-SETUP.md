# NixOS Plymouth Theme Setup

This guide will help you install and configure your custom animated Plymouth boot screen theme on NixOS.

## Files Created

- `nix-animated.plymouth` - Theme configuration
- `nix-animated.script` - Animation script
- `progress-1.png` through `progress-98.png` - Animation frames

## Installation Instructions

### Option 1: From GitHub (Recommended)

Once you've pushed this repository to GitHub, you can reference it directly in your NixOS configuration.

#### Using Flakes

Add this flake as an input to your configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-plymouth = {
      url = "github:YOUR-USERNAME/nix-plymouth";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-plymouth, ... }: {
    nixosConfigurations.yourHost = nixpkgs.lib.nixosSystem {
      modules = [
        nix-plymouth.nixosModules.default
        {
          boot.plymouth.themes.nix-animated.enable = true;

          # Optional: Enable silent boot for cleaner look
          boot.consoleLogLevel = 3;
          boot.kernelParams = [ "quiet" "splash" ];
        }
      ];
    };
  };
}
```

#### Without Flakes

For traditional NixOS configurations:

```nix
{ config, pkgs, ... }:

let
  nix-plymouth = pkgs.fetchFromGitHub {
    owner = "YOUR-USERNAME";
    repo = "nix-plymouth";
    rev = "main"; # or specific commit hash
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  plymouthTheme = pkgs.callPackage nix-plymouth { };
in
{
  boot.plymouth = {
    enable = true;
    theme = "nix-animated";
    themePackages = [ plymouthTheme ];
  };

  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" ];
}
```

**Note:** To get the correct sha256 hash, first use all zeros, run `nixos-rebuild`, and it will show you the correct hash in the error message.

### Option 2: Using a Local Package

Add this to your NixOS configuration (`/etc/nixos/configuration.nix` or a flake):

```nix
{ config, pkgs, ... }:

let
  nixAnimatedPlymouth = pkgs.stdenv.mkDerivation {
    name = "plymouth-nix-animated";
    src = /home/simon/Documents/nix-plymouth;

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
  };
in
{
  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    theme = "nix-animated";
    themePackages = [ nixAnimatedPlymouth ];
  };

  # Optional: Enable silent boot for cleaner look
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" ];
}
```

### Option 3: System-Wide Installation

Alternatively, manually copy files to the Plymouth themes directory:

```bash
# Create theme directory
sudo mkdir -p /etc/plymouth/themes/nix-animated

# Copy theme files
sudo cp nix-animated.plymouth /etc/plymouth/themes/nix-animated/
sudo cp nix-animated.script /etc/plymouth/themes/nix-animated/
sudo cp progress-*.png /etc/plymouth/themes/nix-animated/
```

Then add to your NixOS configuration:

```nix
{
  boot.plymouth = {
    enable = true;
    theme = "nix-animated";
  };

  # Optional: Enable silent boot
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" ];
}
```

## Applying the Configuration

After updating your configuration:

```bash
# Rebuild your system
sudo nixos-rebuild switch

# Or for testing without affecting boot:
sudo nixos-rebuild test
```

## Testing the Theme

To preview the theme without rebooting:

```bash
# This requires a tty (Ctrl+Alt+F2)
sudo plymouthd --debug --debug-file=/tmp/plymouth-debug.log
sudo plymouth show-splash
# Wait a few seconds to see animation
sudo plymouth quit
```

## Customization Options

### Adjusting Animation Speed

Edit `nix-animated.script` and modify the refresh callback to control speed:

```script
# Slower animation - update every other frame
fun refresh_callback() {
    if (refresh_count % 2 == 0) {
        current_frame++;
        if (current_frame > num_frames)
            current_frame = 1;
        animation_sprite.SetImage(animation_images[current_frame]);
    }
    refresh_count++;
}
```

### Changing Animation Size

The animation automatically centers on screen. If you want to scale the images, consider preprocessing them:

```bash
# Install imagemagick if needed
nix-shell -p imagemagick

# Resize all images to 50% (example)
for img in progress-*.png; do
    convert "$img" -resize 50% "resized-$img"
done
```

## Troubleshooting

### Theme Not Showing

1. Check Plymouth is enabled: `systemctl status plymouth-start.service`
2. Verify theme is installed: `plymouth-set-default-theme --list`
3. Check kernel parameters include `splash`: `cat /proc/cmdline`
4. Review logs: `journalctl -u plymouth-start.service`

### Black Screen on Boot

- Ensure `quiet splash` kernel parameters are set
- Try removing `nomodeset` if present
- Some graphics drivers may need additional configuration

### Animation Not Smooth

- The default refresh rate may vary by system
- Consider reducing the number of frames by using every 2nd or 3rd image
- Check system performance during boot

## File Structure

```
nix-plymouth/
├── nix-animated.plymouth    # Theme configuration
├── nix-animated.script       # Animation logic
├── progress-1.png           # Frame 1
├── progress-2.png           # Frame 2
├── ...
└── progress-98.png          # Frame 98
```

## Additional Resources

- [Plymouth Documentation](https://www.freedesktop.org/wiki/Software/Plymouth/)
- [NixOS Plymouth Options](https://search.nixos.org/options?query=boot.plymouth)
- [Plymouth Scripting Tutorial](https://www.freedesktop.org/wiki/Software/Plymouth/Scripts/)
