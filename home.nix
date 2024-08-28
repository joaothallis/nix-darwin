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
    extraConfig = {
      commit = {
        verbose = true;
      };
    };
  };
  programs.neovim = {
    defaultEditor = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [ ];
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      gs = "git status";
      gd = "git diff";
      gl = "git pull --prune";
      gp = "git push";
      glog = "git log --oneline";
      gc = "git commit --patch";
      gca = "git commit --patch --amend";
      gpr = "gh pr create --assignee @me";
      r = "request_review";
      dps = "docker compose ps";
      u = "docker compose -f docker-compose-arm.yml up -d";
      d = "docker compose down";
      n = "nix-shell --command fish";
      nd = "nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ~/.config/nix-darwin";
      mf = "mix format";
      mc = "mix credo --strict";
      md = "mix dialyzer";
      m = "mix test";
      mt = "mix test --cover";
      mtf = "mix test --failed";
      t = "tmux_new";
      ts = "tmux list-sessions";
      ta = "tmux attach";
      c = "tmux choose-session";
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
