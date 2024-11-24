{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "24.11";
  programs.git = {
    enable = true;
    userName = "João Thallis";
    userEmail = "joaothallis@icloud.com";
    signing.key = "DC135DE53C8BF8726229A2FADC9B097428897B78";
    extraConfig = {
      commit = {
        verbose = true;
        gpgSign = true;
      };
    };
  };
  programs.neovim = {
    defaultEditor = true;
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      # not working with vscode 1.93.1
      # github.copilot-chat
    ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ". ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish";
    shellAliases = {
      gs = "git status";
      gd = "git diff";
      gl = "git pull --prune";
      gp = "git push";
      glog = "git log --oneline";
      gc = "git commit --patch";
      gca = "git commit --patch --amend";
      gr = "git reset --hard";
      gcd = "git checkout develop";
      gpr = "gh pr create --assignee @me";
      r = "request_review";
      dps = "docker compose ps";
      u = "docker compose -f docker-compose-arm.yml up -d";
      d = "docker compose down";
      n = "nix-shell --command fish";
      nd = "nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ~/.config/nix-darwin";
      mf = "mix format";
      mc = "mix credo --strict";
      md = "MIX_ENV=test mix dialyzer";
      m = "mix test";
      mt = "mix test --cover";
      mtf = "mix test --failed";
      t = "tmux_new";
      ts = "tmux list-sessions";
      ta = "tmux attach";
      c = "tmux choose-session";
      uuid = "uuidgen | pbcopy";
      f = "aerospace macos-native-fullscreen";
    };
    shellAbbrs = {
      g = "git";
      fix = "git checkout -b fix/";
      d = "docker";
      k = "kubectl";
    };
    functions = {
      tmux_new = ''
        set session (basename (pwd))
        if test -n "$TMUX"
            tmux new -s $session -d
            set session (string replace -a . _ $session)
            tmux switch-client -t $session
        else
            tmux new -t $session
        end
      '';
    };
  };

  programs.home-manager.enable = true;
}
