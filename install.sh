#!/bin/bash

username=$(whoami)
hostname=$(scutil --get LocalHostName)
homedir="$HOME"
platform="aarch64-darwin" # TODO: Handle different architectures

# Install prerequisites
if ! command -v brew >/dev/null 2>&1; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Post processing
  echo >> /Users/${username}/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${username}/.zprofile
fi
if ! command -v nix >/dev/null 2>&1; then
  # Install nix
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
fi

# Clear build directory
rm -rf build

# Copy all source configuration to build directory
cp -r src build

# Hydrate source
for file in $(find build -type f); do
  sed -i '' "s|{username}|$username|g" $file
  sed -i '' "s|{hostname}|$hostname|g" $file
  sed -i '' "s|{homedir}|$homedir|g" $file
  sed -i '' "s|{platform}|$platform|g" $file
done

# Temporarily track build dir in git to resolve error
git add -f build

# Rebuild with hydrated configuration
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake ./build
else
  sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake ./build
fi

# Untrack build directory from git
git rm --cached -r build >/dev/null 2>&1

# After Install configurations
open -na "IntelliJ IDEA.app" --args installPlugins IdeaVIM org.jetbrains.AceJump IdeaVim-EasyMotion eu.theblob42.idea.whichkey
