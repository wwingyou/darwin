#!/bin/bash

# Install prerequisites
if ! command -v brew >/dev/null 2>&1; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
username=$(whoami)
hostname=$(scutil --get LocalHostName)
homedir="$HOME"
platform="aarch64-darwin" # TODO: Handle different architectures

for file in $(find build -type f); do
  sed -i '' "s|{username}|$username|g" $file
  sed -i '' "s|{hostname}|$hostname|g" $file
  sed -i '' "s|{homedir}|$homedir|g" $file
  sed -i '' "s|{platform}|$platform|g" $file
done

# Rebuild with hydrated configuration
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake ./build
else
  sudo nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake.build
fi
