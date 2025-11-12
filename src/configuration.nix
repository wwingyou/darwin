{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
    vim
  ];

  environment.pathsToLink = [
    "/share/zsh"
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  
  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  
  # Used for backwards compatibility, please rad the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  
  # Default system settings.
  system.defaults = {
  
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
    };
    
    dock = {
      autohide = true;
    };
    
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # 64 = Show Spotlight search (⌘Space)
          "64" = { enabled = false; };
          # 65 = Show Finder search window (⌥⌘Space)
          "65" = { enabled = false; };
        };
      };
    };
  };
  
  # Apply immediately after defaults are written.
  #    (avoids needing a reboot or manual toggling)
  system.activationScripts.applySymbolicHotKeys.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
  '';
  
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "{platform}";
  nixpkgs.config.allowUnfree = true;
  
  # Swap caps-lock and ctrl
  launchd.user.agents.swap-caps-ctrl = {
    script = ''
      /usr/bin/hidutil property --set '{
        "UserKeyMapping": [
          {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0},
          {"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x700000039}
        ]
      }'
    '';
  
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
  
  # Set keyboard layout to ABC when pressing ESC
  services.skhd = {
    enable = true;
    skhdConfig = ''
      escape -> : /opt/homebrew/bin/im-select com.apple.keylayout.ABC
    '';
  };
  
  # Set user for Homebrew
  system.primaryUser = "{username}";
  
  # Install user packages and applications with Homebrew
  homebrew = {
    enable = true;
    taps = [
      "daipeihust/tap"
    ];
    brews = [
      "im-select"
      "cmake"
    ];
    casks = [
      "intellij-idea"
      "datagrip"
      "chatgpt"
      "raycast"
      "arc"
    ];
  };
  
  # Home manager settings.
  users.users.al02030147 = {
    name = "{username}";
    home = "{homedir}";
  };

  fonts.packages = with pkgs; [
    pkgs.nerd-fonts._0xproto
  ];
}
