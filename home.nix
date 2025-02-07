{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "24.11";
  programs = {
    git = {
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
      ignores = [ ".lexical" ];
    };
    neovim = {
      defaultEditor = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      # not working with vscode 1.93.1
      # github.copilot-chat
      asvetliakov.vscode-neovim
    ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      . ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
      ulimit -n 524288

      set -gx CHROME_BINARY /run/current-system/sw/bin/google-chrome-stable
      set -gx CHROMEDRIVER_BINARY /run/current-system/sw/bin/chromedriver
    '';
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
      gch = "git checkout";
      gc- = "git checkout -";
      gb = "git checkout -b";
      gcai = "git --no-pager diff HEAD | mods 'write a commit message for this patch. also write the long commit message. use semantic commits. break the lines at 80 chars' | tr -s ' ' >.git/gcai; git commit -a -F .git/gcai -e";
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
      uuid_string = "uuidgen | sed 's/^/\"/' | sed 's/$/\"/' | pbcopy";
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
      open_coverage_report = ''
        open cover/Elixir.$argv.html
      '';
      run_mix_test = ''
        # Get the list of file paths from `git status`
        set file_paths (git status --porcelain=v1 --untracked-files=all | awk '{print $2}' | grep .ex)

        # Initialize an array to store the transformed paths
        set transformed_paths

        # Process the file paths
        for path in $file_paths
            if string match -q "lib/*" $path
                # Replace 'lib/' with 'test/' and change '.ex' to '_test.exs'
                set transformed_path (echo $path | sed -E 's|^lib/|test/|; s|\.ex$|_test.exs|')
                set transformed_paths $transformed_paths $transformed_path
            else
                # Keep the path as is
                set transformed_paths $transformed_paths $path
            end
        end

        # Output the mix test command
        echo "mix test $transformed_paths"

        # Run the mix test command
        eval "mix test $transformed_paths"
            	'';
    };
  };

  programs.home-manager.enable = true;
}
