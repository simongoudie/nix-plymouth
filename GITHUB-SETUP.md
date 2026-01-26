# Publishing to GitHub

This guide will help you publish your Plymouth theme to GitHub so you can reference it in your NixOS configuration.

## Prerequisites

- A GitHub account
- Git installed on your system
- The GitHub CLI (`gh`) or web access to GitHub

## Step 1: Initialize Git Repository

```bash
cd /home/simon/Documents/nix-plymouth

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: NixOS Plymouth animated theme"
```

## Step 2: Create GitHub Repository

### Option A: Using GitHub CLI (Recommended)

```bash
# Login to GitHub if not already logged in
gh auth login

# Create a new public repository
gh repo create nix-plymouth --public --source=. --remote=origin

# Push your code
git push -u origin main
```

### Option B: Using GitHub Web Interface

1. Go to [https://github.com/new](https://github.com/new)
2. Repository name: `nix-plymouth`
3. Description: "Animated Plymouth boot screen theme for NixOS"
4. Choose **Public**
5. **Do NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

Then push your local repository:

```bash
# Replace YOUR-USERNAME with your GitHub username
git remote add origin https://github.com/YOUR-USERNAME/nix-plymouth.git
git branch -M main
git push -u origin main
```

## Step 3: Update Documentation

After creating the repository, update the following files to replace `YOUR-USERNAME` with your actual GitHub username:

1. Edit `README.md` - Replace all instances of `YOUR-USERNAME`
2. Edit `NIXOS-SETUP.md` - Replace all instances of `YOUR-USERNAME`

Then commit and push the changes:

```bash
git add README.md NIXOS-SETUP.md
git commit -m "Update documentation with GitHub username"
git push
```

## Step 4: Test the Installation

Now test that your theme can be fetched from GitHub:

### For Flake Users

Create a test flake or update your existing one:

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
        }
      ];
    };
  };
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#yourHost
```

### For Non-Flake Users

First, get the correct hash:

```bash
# This will fail but give you the correct hash
nix-prefetch-github YOUR-USERNAME nix-plymouth
```

Use the hash in your configuration:

```nix
{ config, pkgs, ... }:

let
  nix-plymouth = pkgs.fetchFromGitHub {
    owner = "YOUR-USERNAME";
    repo = "nix-plymouth";
    rev = "main";
    sha256 = "HASH-FROM-PREFETCH";
  };

  plymouthTheme = pkgs.callPackage nix-plymouth { };
in
{
  boot.plymouth = {
    enable = true;
    theme = "nix-animated";
    themePackages = [ plymouthTheme ];
  };
}
```

## Step 5: Add a License (Optional but Recommended)

Create a LICENSE file if you want to specify how others can use your theme:

```bash
# Example: Create MIT License
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 YOUR-NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

git add LICENSE
git commit -m "Add MIT license"
git push
```

## Maintenance

### Updating Your Theme

When you make changes to your theme:

```bash
git add .
git commit -m "Description of changes"
git push
```

### Using Specific Commits in NixOS

For reproducibility, use specific commit hashes instead of `main`:

```nix
{
  inputs.nix-plymouth.url = "github:YOUR-USERNAME/nix-plymouth/COMMIT-HASH";
}
```

Or for non-flakes:

```nix
nix-plymouth = pkgs.fetchFromGitHub {
  owner = "YOUR-USERNAME";
  repo = "nix-plymouth";
  rev = "COMMIT-HASH";
  sha256 = "...";
};
```

### Tagging Releases

Create version tags for stable releases:

```bash
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

Then reference by tag:

```nix
{
  inputs.nix-plymouth.url = "github:YOUR-USERNAME/nix-plymouth/v1.0.0";
}
```

## Troubleshooting

### Authentication Issues

If you have trouble pushing to GitHub:

```bash
# Use GitHub CLI
gh auth login

# Or configure SSH keys
# See: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
```

### Hash Mismatches

If you get hash mismatches when others try to use your flake:

```bash
# Update flake.lock
nix flake update

# Or let Nix update automatically
nix flake lock --update-input nix-plymouth
```

## Sharing Your Theme

Once published, others can use your theme by following the instructions in `README.md`. Share your repository URL:

```
https://github.com/YOUR-USERNAME/nix-plymouth
```

Consider adding topics to your GitHub repository:
- `nixos`
- `plymouth`
- `boot-screen`
- `theme`
- `animation`

This makes it easier for others to discover your theme!
