{
  description = "João's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            # required for github.com/github/copilot.vim
            pkgs.nodejs_22
            # to format json
            pkgs.jq
            pkgs.asdf-vm
            pkgs.neovim
            pkgs.tig
            pkgs.gh
            pkgs.gh-copilot
            pkgs.google-cloud-sdk
            pkgs.gnupg
            pkgs.pinentry_mac
            pkgs.yubikey-manager
            pkgs.ripgrep
            pkgs._1password-cli
            pkgs.nixfmt-rfc-style
          ];

          environment.variables = {
            EDITOR = "nvim";
          };

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          # nix.package = pkgs.nix;

          # required for home-manager
          users.users."joao".home = "/Users/joao";

          environment.systemPath = [ "/opt/homebrew/bin" ];

          homebrew.onActivation.autoUpdate = true;
          homebrew.onActivation.upgrade = true;

          homebrew = {
            enable = true;
            brews = [
              "openssl@3"
              "gossip"
            ];
            casks = [
              "1password"
              "slack"
              "microsoft-edge@beta"
              "vial"
              "obs"
              "cursor"
              "discord"
              "google-chrome@dev"
              "eloston-chromium"
              "alacritty"
              "stremio"
              "utm@beta"
              "chromedriver@beta"
              "rio"
            ];
            masApps = {
              "1Password for Safari" = 1569813296;
              "AdGuard for Safari" = 1440147259;
              "WhatsApp Messenger" = 310633997;
              "Telegram" = 747648890;
              "Yubico Authenticator" = 1497506650;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina

          programs.tmux.enable = true;
          programs.tmux.enableVim = true;
          programs.tmux.extraConfig = ''
                        	set-option -g focus-events on
            		set-option -a terminal-features 'xterm-256color:RGB'

            		set -g default-command fish
          '';

          services.aerospace.enable = true;
          # i3 like config 
          services.aerospace.settings = {
            enable-normalization = false;
            enable-normalization-opposite-orientation-for-nested-containers = false;
            on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
            mode.main.binding = {
              alt-j = "focus --boundaries-action wrap-around-the-workspace left";
              alt-k = "focus --boundaries-action wrap-around-the-workspace down";
              alt-l = "focus --boundaries-action wrap-around-the-workspace up";
              alt-semicolon = "focus --boundaries-action wrap-around-the-workspace right";

              alt-shift-j = "move left";
              alt-shift-k = "move down";
              alt-shift-l = "move up";
              alt-shift-semicolon = "move right";

              # split has no effect when enable-normalization-flatten-container is disabled
              # alt-h = "split horizontal";
              # alt-v = "split vertical";

              alt-enter = "macos-native-fullscreen";

              alt-s = "layout v_accordion";
              alt-w = "layout h_accordion";
              alt-e = "layout tiles horizontal vertical";

              alt-shift-space = "layout floating tiling";

              alt-1 = "workspace 1";
              alt-2 = "workspace 2";
              alt-3 = "workspace 3";
              alt-4 = "workspace 4";
              alt-5 = "workspace 5";
              alt-6 = "workspace 6";
              alt-7 = "workspace 7";
              alt-8 = "workspace 8";
              alt-9 = "workspace 9";
              alt-0 = "workspace 10";

              alt-shift-1 = "move-node-to-workspace 1";
              alt-shift-2 = "move-node-to-workspace 2";
              alt-shift-3 = "move-node-to-workspace 3";
              alt-shift-4 = "move-node-to-workspace 4";
              alt-shift-5 = "move-node-to-workspace 5";
              alt-shift-6 = "move-node-to-workspace 6";
              alt-shift-7 = "move-node-to-workspace 7";
              alt-shift-8 = "move-node-to-workspace 8";
              alt-shift-9 = "move-node-to-workspace 9";
              alt-shift-0 = "move-node-to-workspace 10";

              alt-shift-c = "reload-config";

              alt-r = "mode resize";
            };
            mode.resize.binding = {
              h = "resize width -50";
              j = "resize height +50";
              k = "resize height -50";
              l = "resize width +50";
              enter = "mode main";
              esc = "mode main";
            };
          };

          services.tailscale.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 4;

          nixpkgs.config.allowUnfree = true;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Joaos-MacBook-Pro
      darwinConfigurations."Joaos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          { home-manager.users."joao" = import ./home.nix; }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;

              user = "joao";

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              mutableTaps = false;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Joaos-MacBook-Pro".pkgs;
    };
}
