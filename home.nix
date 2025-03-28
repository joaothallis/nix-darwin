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
      ignores = [
        ".lexical"
        ".projections.json"
      ];
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig = ''
          vim.opt.number = true

           local o = vim.o
        local g = vim.g

        o.clipboard = "unnamedplus"

        o.number = true

        vim.opt.numberwidth = 1

        o.swapfile = false

            g.markdown_fenced_languages = {
            "python", "elixir", "bash", "dockerfile", 'sh=bash'
        }
      '';
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            	        require'nvim-treesitter.configs'.setup {
                    highlight = {enable = true}
                }
            	      '';
        }
        vim-elixir
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            require'lspconfig'.lexical.setup {
                cmd = { 'lexical' }
            }
            require'lspconfig'.ts_ls.setup{}

            -- Basic LSP keybindings
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
             local telescope = require("telescope")
                telescope.setup({
                    defaults = {
                        vimgrep_arguments = {
                            "rg", "--color=never", "--no-heading", "--with-filename",
                            "--line-number", "--column", "--smart-case", "--hidden",
                            "--glob=!.git"
                        }
                    }
                })
                local builtin = require("telescope.builtin")
                vim.keymap.set("n", "<leader>ff", builtin.git_files, {})
                vim.keymap.set('n', '<leader>fg', builtin.live_grep,
                               {desc = 'Telescope live grep'})
            	  '';
        }
        vim-projectionist
        vim-test
        vim-fugitive
        {
          plugin = gitlinker-nvim;
          type = "lua";
          config = "require'gitlinker'.setup()";
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            	  require('gitsigns').setup{
            	    on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                  if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                  else
                    gitsigns.nav_hunk('next')
                  end
                end)

                map('n', '[c', function()
                  if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                  else
                    gitsigns.nav_hunk('prev')
                  end
                end)

                -- Actions
                map('n', '<leader>hs', gitsigns.stage_hunk)
                map('n', '<leader>hr', gitsigns.reset_hunk)

                map('v', '<leader>hs', function()
                  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end)

                map('v', '<leader>hr', function()
                  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end)

                map('n', '<leader>hS', gitsigns.stage_buffer)
                map('n', '<leader>hR', gitsigns.reset_buffer)
                map('n', '<leader>hp', gitsigns.preview_hunk)
                map('n', '<leader>hi', gitsigns.preview_hunk_inline)

                map('n', '<leader>hb', function()
                  gitsigns.blame_line({ full = true })
                end)

                map('n', '<leader>hd', gitsigns.diffthis)

                map('n', '<leader>hD', function()
                  gitsigns.diffthis('~')
                end)

                map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
                map('n', '<leader>hq', gitsigns.setqflist)

                -- Toggles
                map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
                map('n', '<leader>td', gitsigns.toggle_deleted)
                map('n', '<leader>tw', gitsigns.toggle_word_diff)

                -- Text object
                map({'o', 'x'}, 'ih', gitsigns.select_hunk)
              end
            	  }
            	  '';
        }

        file-line
        vim-projectionist

        {
          plugin = avante-nvim;
          type = "lua";
          config = ''
            	      require('avante_lib').load()

            	  require("avante").setup({
            	   provider = "openai",
            	   auto_suggestions_provider = "openai",
                       behaviour = {auto_suggestions = false}
            	  })
            	  '';

        }

      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
      github.copilot-chat
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
      gcai = "git --no-pager diff HEAD | mods \"write a commit message for this patch. also write the long commit message. use semantic commits. break the lines at 80 chars. The current branch is $(git rev-parse --abbrev-ref HEAD).\" | tr -s ' ' >.git/gcai; git commit -a -F .git/gcai -e";
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
      ai_branch_name = ''
        	git --no-pager diff HEAD | mods 'Generate a concise branch name based on this diff. Optionally include a prefix like "feat/", "fix/", "chore/", or similar if it fits the changes; otherwise, use no prefix. Make it a short, meaningful description. The current branch is (git rev-parse --abbrev-ref HEAD). Keep it under 30 characters total. Return only one name.' | grep -v 'Conversation saved' | tr -s ' ' | head -n 1
      '';
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
        set module (echo $argv[1] | sed 's/Test$//')
        open cover/Elixir.$module.html
      '';
      test_modified_files = ''
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
