# NixOS Animated Plymouth Theme

An animated boot screen theme for Plymouth on NixOS, featuring a smooth 98-frame animation.

## Preview

This theme displays an animated sequence during system boot, providing a polished visual experience for your NixOS system.

## Installation

### Using Flakes (Recommended)

Add this flake as an input to your NixOS configuration:

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

          # Optional: Enable silent boot for cleaner appearance
          boot.consoleLogLevel = 3;
          boot.kernelParams = [ "quiet" "splash" ];
        }
      ];
    };
  };
}
```

### Alternative: Manual Package Reference

If you prefer not to use the NixOS module:

```nix
{
  inputs.nix-plymouth.url = "github:YOUR-USERNAME/nix-plymouth";

  outputs = { self, nixpkgs, nix-plymouth, ... }: {
    nixosConfigurations.yourHost = nixpkgs.lib.nixosSystem {
      modules = [
        {
          boot.plymouth = {
            enable = true;
            theme = "nix-animated";
            themePackages = [ nix-plymouth.packages.x86_64-linux.default ];
          };
        }
      ];
    };
  };
}
```

### Non-Flakes Installation

For traditional NixOS configurations:

```nix
{ config, pkgs, ... }:

let
  nix-plymouth = pkgs.fetchFromGitHub {
    owner = "YOUR-USERNAME";
    repo = "nix-plymouth";
    rev = "main"; # or specific commit hash
    sha256 = "0000000000000000000000000000000000000000000000000000"; # Update this
  };

  plymouthTheme = pkgs.callPackage nix-plymouth { };
in
{
  boot.plymouth = {
    enable = true;
    theme = "nix-animated";
    themePackages = [ plymouthTheme ];
  };

  # Optional: Enable silent boot
  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" "splash" ];
}
```

To get the correct sha256, first use a dummy hash (all zeros), then run `nixos-rebuild` and it will show you the correct hash in the error message.

## Testing

After applying your configuration with `nixos-rebuild switch`, test the theme:

```bash
# Switch to a TTY (Ctrl+Alt+F2)
sudo plymouthd --debug --debug-file=/tmp/plymouth-debug.log
sudo plymouth show-splash
# Wait a few seconds to see the animation
sudo plymouth quit
```

## Customization

### Animation Speed

The animation refresh rate is controlled by Plymouth's default refresh function. To adjust the speed, you can modify `nix-animated.script` and rebuild.

### Screen Position

The animation is automatically centered on screen. You can modify the sprite positioning in the script file if needed.

## File Structure

```
.
├── flake.nix                 # Nix flake definition
├── default.nix               # Non-flake package definition
├── nix-animated.plymouth     # Plymouth theme configuration
├── nix-animated.script       # Animation script (98 frames)
├── progress-1.png            # Animation frame 1
├── progress-2.png            # Animation frame 2
├── ...
└── progress-98.png           # Animation frame 98
```

## Troubleshooting

### Theme Not Appearing

1. Verify Plymouth is enabled: `systemctl status plymouth-start.service`
2. Check available themes: `plymouth-set-default-theme --list`
3. Ensure kernel parameters include `splash`: `cat /proc/cmdline`
4. Review logs: `journalctl -u plymouth-start.service`

### Build Errors

If you encounter hash mismatches with `fetchFromGitHub`, update the `sha256` field with the correct hash from the error message.

## License

MIT

## Credits

Created for NixOS with love.
