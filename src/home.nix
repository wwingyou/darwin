{ config, pkgs, lib, ... }:

let
  clone = repo: dest: ''
    if [ ! -d "${dest}/.git" ]; then
      ${pkgs.git}/bin/git clone --depth=1 ${repo} ${dest}
    else
      ${pkgs.git}/bin/git -C ${dest} pull --ff-only || true
    fi
  '';
  spaceship = pkgs.fetchFromGitHub {
    owner = "spaceship-prompt";
    repo = "spaceship-prompt";
    rev = "v4.19.0";
    hash = "sha256-g0hiUyGVaUA9Jg5UHFEyf1ioUnMb2cp7tOrtTFLMtvc=";
  };
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "{username}";
  home.homeDirectory = "{homedir}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    git
    cowsay
    tree
    tmux
    neovim
    kitty
    fzf
    obsidian
    aerospace
    httpie
    ripgrep
  ];

  # Execute once when darwin-rebuild switch runs
  home.activation.cloneRepositories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
      ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    ${clone "https://github.com/wwingyou/minivim" "$HOME/.config/nvim"}
  '';

  home.activation.makeCustomFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.zshrc_custom" ]; then
      touch "$HOME/.zshrc_custom"
      echo "# zshrc logic that is out of darwin management should be placed here." > "$HOME/.zshrc_custom"
    fi
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".tmux.conf".source = dotfiles/tmuxrc;
    ".config/kitty/kitty.conf".source = dotfiles/kitty/rc;
    ".config/kitty/current-theme.conf".source = dotfiles/kitty/themerc;
    ".oh-my-zsh/custom/themes/spaceship.zsh-theme".source = "${spaceship}/spaceship.zsh-theme";
    ".oh-my-zsh/custom/themes/spaceship-prompt".source = "${spaceship}";
    ".spaceshiprc.zsh".source = dotfiles/spaceshiprc.zsh;
    ".ideavimrc".source = dotfiles/ideavimrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/al02030147/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autocd = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };

    shellAliases = {
      vim = "nvim";
    };

    envExtra = builtins.readFile dotfiles/zsh/env.zsh;
    initContent = builtins.readFile dotfiles/zsh/rc.zsh;

    oh-my-zsh = {
      enable = true;
      theme = "spaceship";
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      plugins = [
        "git"
        "z"
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.obsidian = {
    enable = true;
    vaults."note" = {
      enable = true;
      target = "Notes";
    };
  };

  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    userSettings = {
      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };
      mode.main.binding = {
        alt-enter = "fullscreen";
        alt-esc = "layout floating tiling";

        # See: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#resize
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
        alt-shift-1 = [ "move-node-to-workspace 1" "workspace 1" ];
        alt-shift-2 = [ "move-node-to-workspace 2" "workspace 2" ];
        alt-shift-3 = [ "move-node-to-workspace 3" "workspace 3" ];
        alt-shift-4 = [ "move-node-to-workspace 4" "workspace 4" ];
        alt-shift-5 = [ "move-node-to-workspace 5" "workspace 5" ];
        alt-shift-6 = [ "move-node-to-workspace 6" "workspace 6" ];
        alt-shift-7 = [ "move-node-to-workspace 7" "workspace 7" ];
        alt-shift-8 = [ "move-node-to-workspace 8" "workspace 8" ];
        alt-shift-9 = [ "move-node-to-workspace 9" "workspace 9" ];

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
        alt-tab = "workspace-back-and-forth";
        # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
        alt-shift-enter = "move-workspace-to-monitor --wrap-around next";
      };
    };
  };
}
