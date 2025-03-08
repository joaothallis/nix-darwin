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
          environment = {
            systemPackages = [
              pkgs.google-chrome
              pkgs.chromedriver
              # required for github.com/github/copilot.vim
              pkgs.nodejs_22
              pkgs.elixir_1_18
              # to format json
              pkgs.jq
              pkgs.asdf-vm
              pkgs.mods
              pkgs.tig
              pkgs.gh
              pkgs.gh-copilot
              pkgs.google-cloud-sdk
              pkgs.gnupg
              pkgs.pinentry_mac
              pkgs.yubikey-manager
              pkgs.ripgrep
              pkgs._1password-cli
              pkgs.postman
              pkgs.nixfmt-rfc-style
            ];

            variables = {
              EDITOR = "nvim";
              KERL_CONFIGURE_OPTIONS = "--disable-jit";
            };
          };

          # required for home-manager
          users.users."joao".home = "/Users/joao";

          environment.systemPath = [ "/opt/homebrew/bin" ];

          homebrew.onActivation = {
            autoUpdate = true;
            upgrade = true;
          };

          homebrew = {
            enable = true;
            brews = [
              "openssl@3"
              "gossip"
            ];
            casks = [
              "1password"
              "slack"
              "microsoft-edge"
              "vial"
              "obs"
              "steam"
              "zoom"
              "cursor"
              "claude"
              "discord"
              "eloston-chromium"
              "alacritty"
              "stremio"
              "utm@beta"
              "rio"
              "bisq"
            ];
            masApps = {
              "1Password for Safari" = 1569813296;
              "AdGuard for Safari" = 1440147259;
              "WhatsApp Messenger" = 310633997;
              "Telegram" = 747648890;
              "Yubico Authenticator" = 1497506650;
              "Perplexity: Ask Anything" = 6714467650;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina

          programs.tmux = {
            enable = true;
            enableVim = true;
            extraConfig = ''
                          	set-option -g focus-events on
              		set-option -a terminal-features 'rio:RGB'

              		set -g default-command fish
              		set -g history-limit 4000
            '';
          };

          # Auto upgrade nix package and the daemon service.
          services = {
            tailscale.enable = true;
          };

          system = {
            defaults.trackpad.Clicking = true;
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 4;

          };

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
