{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.helix = {
    enable = true;

    # Additional packages needed for formatters and language servers
    extraPackages = with pkgs; [
      # Formatters
      nodePackages.prettier
      python311Packages.black
      shfmt
      nixfmt-classic
      deno
      # Language servers (only commonly available ones)
      marksman
      nodePackages.vscode-json-languageserver
      yaml-language-server
      ansible-language-server
      nodePackages.bash-language-server
      python311Packages.python-lsp-server
      nodePackages.vscode-langservers-extracted # provides html, css, json, eslint LSPs
      nodePackages.typescript-language-server
      terraform-ls
      cmake-language-server
      rust-analyzer
      taplo
      gopls
      golangci-lint-langserver
      # Note: Some LSPs like awk-language-server, graphql-language-service,
      # bufls, pbkit may need to be installed separately or may not be in nixpkgs
    ];

    settings = {
      theme = "nord";

      editor = {
        clipboard-provider = "termcode";
        line-number = "relative";
        bufferline = "always";
        default-line-ending = "lf";
        end-of-line-diagnostics = "disable";
        continue-comments = false;
        completion-replace = true;
        true-color = true;
        text-width = 63;
        auto-pairs = false;
        shell = [
          "${pkgs.nushell}/bin/nu"
          "--no-config-file"
          "--no-history"
          "--no-newline"
          "--commands"
        ];

        statusline = {
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
          left = [
            "file-modification-indicator"
            "mode"
            "spinner"
          ];
          center = [
            "position"
            "position-percentage"
            "total-line-numbers"
            "file-name"
            "version-control"
          ];
          right = [
            "diagnostics"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
        };

        whitespace = {
          render = "all";
        };

        auto-save = {
          enable = true;
          focus-lost = true;
        };

        indent-guides = {
          render = false;
        };

        file-picker = {
          hidden = false;
          follow-symlinks = true;
          git-ignore = true;
        };

        soft-wrap = {
          enable = true;
        };

        lsp = {
          enable = true;
          display-inlay-hints = false;
          display-messages = false;
          display-progress-messages = false;
        };

        inline-diagnostics = {
          cursor-line = "disable";
          other-lines = "disable";
        };

        cursor-shape = {
          normal = "block";
          select = "underline";
          insert = "bar";
        };
      };

      keys.normal = {
        # AI/GPT integration
        "A-c" = [ ":pipe sgpt --code --temperature 0.3 --no-cache 'Replace this code with a better version and complete it.'" ];
        "A-C" = [
          ":sh echo working..."
          ":pipe-to cat > /tmp/helix-gpt"
          ":append-output cat /tmp/helix-gpt | sgpt --code --temperature 0.3 --no-cache 'Finish this code. Start typing from where I left.'"
          ":sh echo done!"
        ];

        # Basic navigation and editing
        "tab" = [ "insert_tab" ];
        "\\" = [ "toggle_comments" ];
        "^" = [ "goto_line_start" ];
        "$" = [ "goto_line_end" ];
        "<" = [ "goto_line_start" ];
        ">" = [ "goto_line_end" ];
        "]" = [ "indent" ];
        "[" = [ "unindent" ];
        "G" = [ "goto_last_line" ];

        # File and buffer pickers
        "A-b" = [ "buffer_picker" ];
        "A-f" = [ "file_picker" ];
        "C-f" = [ "file_picker_in_current_directory" ];

        # Yank, paste, delete
        "R" = [ "replace_with_yanked" ];
        "y" = [ "yank" ];
        "Y" = [
          "extend_line_below"
          "yank"
        ];
        "p" = [ "paste_after" ];
        "P" = [ "paste_before" ];
        "d" = [ "delete_selection" ];
        "c" = [ "change_selection" ];

        # Save and window management
        "C-s" = [ ":write!" ];
        "C-down" = [ "jump_view_down" ];
        "C-left" = [ "jump_view_left" ];
        "C-right" = [ "jump_view_right" ];
        "C-up" = [ "jump_view_up" ];

        # Split windows
        "}" = [
          ":vsplit-new"
          "file_picker_in_current_directory"
        ];
        "{" = [
          ":hsplit-new"
          "file_picker_in_current_directory"
        ];

        # Undo/Redo
        "C-r" = [ "redo" ];

        # Backspace and delete behaviors
        "backspace" = [
          "move_char_left"
          "select_mode"
          "delete_selection_noyank"
          "normal_mode"
        ];
        "del" = [
          "select_mode"
          "delete_selection_noyank"
          "normal_mode"
          "move_char_right"
          "move_char_left"
        ];

        # Enter to open line below
        "ret" = [
          "open_below"
          "normal_mode"
        ];

        # Shift navigation with selection
        "S-right" = [
          "move_next_word_end"
          "select_mode"
        ];
        "S-left" = [
          "move_prev_word_start"
          "select_mode"
        ];

        # Select all
        "C-a" = [
          "select_all"
          "select_mode"
        ];

        # New file picker
        "A-ret" = [
          ":new"
          "file_picker_in_current_directory"
        ];

        # Copy, paste, cut operations
        "C-c" = [
          "save_selection"
          "goto_line_start"
          "select_mode"
          "goto_line_end"
          "yank"
          "normal_mode"
          "jump_backward"
          "collapse_selection"
        ];
        "C-v" = [
          "save_selection"
          "goto_line_start"
          "open_above"
          "normal_mode"
          "paste_before"
          "jump_backward"
          "collapse_selection"
        ];
        "C-x" = [
          "goto_line_start"
          "select_mode"
          "goto_line_end"
          "yank"
          "normal_mode"
          "goto_line_start"
          "kill_to_line_end"
          "delete_char_forward"
          "collapse_selection"
        ];

        # Visual line mode
        "V" = [
          "goto_line_start"
          "select_mode"
          "goto_line_end"
        ];

        # TERMUX FIX: Disable Ctrl+Shift+V to prevent freezing
        "C-S-v" = "no_op";
      };

      # Space leader key mappings
      keys.normal.space = {
        "p" = [ "paste_clipboard_after" ];
        "P" = [ "paste_clipboard_before" ];
        "y" = [ "yank_joined_to_clipboard" ];
        "Y" = [ "yank_main_selection_to_clipboard" ];
        "R" = [ "replace_selections_with_clipboard" ];
      };

      # Space + j for jumplist
      keys.normal.space.j = {
        "space" = [ "jumplist_picker" ];
        "ret" = [ "save_selection" ];
        "right" = [ "jump_forward" ];
        "left" = [ "jump_backward" ];
      };

      # g prefix mappings
      keys.normal.g = {
        "^" = [ "goto_line_start" ];
        "$" = [ "goto_line_end" ];
        "q" = {
          "q" = [
            "goto_line_start"
            "select_mode"
            "goto_line_end"
            ":reflow"
            "normal_mode"
          ];
        };
      };

      # t prefix for toggle options
      keys.normal.t = {
        "d" = [ ":set-option file-picker.max-depth 1" ];
        "D" = [ ":set-option file-picker.max-depth null" ];
        "w" = [ ":set-option whitespace.render none" ];
        "W" = [ ":set-option whitespace.render all" ];
        "f" = [
          ":toggle-option auto-format"
          ":get-option auto-format"
        ];
        "g" = [
          ":toggle-option file-picker.git-ignore"
          ":get-option file-picker.git-ignore"
        ];
        "h" = [
          ":toggle-option file-picker.hidden"
          ":get-option file-picker.hidden"
        ];
        "p" = [
          ":toggle-option auto-pairs"
          ":get-option auto-pairs"
        ];
        "q" = [
          ":toggle-option auto-pairs"
          ":get-option auto-pairs"
        ];
        "t" = "@:indent-style ";
      };

      # + prefix for config and reload
      keys.normal."+" = {
        "+" = [ ":reload" ];
        "c" = [ ":config-reload" ];
        "C" = [ ":config-open" ];
        "p" = "@\"%P yd";
      };

      # + g for git operations
      keys.normal."+".g = {
        "o" = [ ":open .git/COMMIT_EDITMSG" ];
        "C" = [ ":run-shell-command git commit --signoff --gpg-sign -F.git/COMMIT_EDITMSG" ];
      };

      # = m for make/task/just
      keys.normal."=".m = {
        "ret" = [ ":run-shell-command make" ];
        "+" = [ ":run-shell-command task" ];
        ")" = [ ":run-shell-command just" ];
      };

      # = t for terraform
      keys.normal."=".t = {
        "i" = [ ":run-shell-command terraform init" ];
        "a" = [ ":run-shell-command terraform apply -auto-approve" ];
        "d" = [ ":run-shell-command terraform destroy -auto-approve" ];
      };

      # = c for cargo
      keys.normal."=".c = {
        "t" = [ ":run-shell-command cargo test -- --nocapture" ];
        "T" = [ ":run-shell-command cargo watch -c -x 'test -- --nocapture'" ];
      };

      # Select mode keybindings
      keys.select = {
        "u" = [ "switch_to_lowercase" ];
        "U" = [ "switch_to_uppercase" ];
        "^" = [ "goto_line_start" ];
        "$" = [ "goto_line_end" ];
        "C-left" = [ "jump_view_left" ];
        "C-right" = [ "jump_view_right" ];
        "C-down" = [ "jump_view_down" ];
        "C-up" = [ "jump_view_up" ];
        "S-right" = [ "move_next_word_end" ];
        "S-left" = [ "move_prev_word_start" ];
        "backspace" = [ "delete_selection_noyank" ];
        "\\" = [
          "toggle_comments"
          "normal_mode"
        ];
        "v" = [
          "move_next_word_end"
          "normal_mode"
          "move_prev_word_start"
          "select_mode"
          "move_next_word_end"
        ];
        "C" = [
          "normal_mode"
          "yank_main_selection_to_clipboard"
        ];
        "V" = [
          "replace_selections_with_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        "C-c" = [
          "yank"
          "select_mode"
          "collapse_selection"
          "normal_mode"
        ];
        "C-v" = [
          "replace_with_yanked"
          "collapse_selection"
          "normal_mode"
        ];
        "C-x" = [
          "delete_selection"
          "select_mode"
          "collapse_selection"
          "normal_mode"
        ];
        "C-s" = [
          ":write"
          "normal_mode"
        ];
        # TERMUX FIX
        "C-S-v" = "no_op";
      };

      # Insert mode keybindings
      keys.insert = {
        "C-left" = [ "jump_view_left" ];
        "C-right" = [ "jump_view_right" ];
        "C-down" = [ "jump_view_down" ];
        "C-up" = [ "jump_view_up" ];
        "C-s" = [
          ":write"
          "normal_mode"
        ];
        "tab" = [ "insert_tab" ];
        # Manual pairing keybindings for insert mode (when auto-pairs is disabled)
        "A-\"" = [ ":insert-output printf '\"\"'" ];
        "A-'" = [ ":insert-output printf \"''\"" ];
        "A-`" = [
          ":insert-output printf '```'"
          "move_char_right"
        ];
        # TERMUX FIX
        "C-S-v" = "no_op";
      };
    };

    # Language configurations
    languages = {
      language = [
        {
          name = "markdown";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "markdown"
            ];
          };
          auto-format = true;
          language-servers = [ "marksman" "gpt" ];
        }
        {
          name = "json";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "json"
            ];
          };
          auto-format = true;
          language-servers = [
            "vscode-json-language-server"
            "gpt"
          ];
        }
        {
          name = "yaml";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser=yaml"
            ];
          };
          auto-format = true;
          language-servers = [
            "yaml-language-server"
            "ansible-language-server"
            "gpt"
          ];
        }
        {
          name = "xml";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--plugin=/usr/lib/node_modules/@prettier/plugin-xml/src/plugin.js"
              "--parser=xml"
              "--single-attribute-per-line=true"
              "--xml-whitespace-sensitivity=ignore"
            ];
          };
          auto-format = true;
          language-servers = [ "gpt" ];
        }
        {
          name = "graphql";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser=graphql"
            ];
          };
          auto-format = true;
          language-servers = [
            "graphql-language-service"
            "gpt"
          ];
        }
        {
          name = "bash";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          formatter = {
            command = "${pkgs.shfmt}/bin/shfmt";
            args = [
              "--binary-next-line"
              "--keep-padding"
              "--indent=2"
            ];
          };
          auto-format = true;
          language-servers = [
            "bash-language-server"
            "gpt"
          ];
        }
        {
          name = "python";
          formatter = {
            command = "${pkgs.python311Packages.black}/bin/black";
            args = [
              "--quiet"
              "-"
            ];
          };
          auto-format = true;
          language-servers = [
            "pylsp"
            "gpt"
          ];
        }
        {
          name = "html";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "html"
            ];
          };
          auto-format = true;
          language-servers = [
            "vscode-html-language-server"
            "gpt"
          ];
        }
        {
          name = "css";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "css"
            ];
          };
          auto-format = true;
          language-servers = [
            "vscode-css-language-server"
            "gpt"
          ];
        }
        {
          name = "javascript";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
          language-servers = [
            "typescript-language-server"
            "gpt"
          ];
        }
        {
          name = "typescript";
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--print-width=79"
              "--prose-wrap=always"
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
          language-servers = [
            "typescript-language-server"
            "gpt"
          ];
        }
        {
          name = "jsx";
          formatter = {
            command = "${pkgs.deno}/bin/deno";
            args = [
              "fmt"
              "--ext=jsx"
              "--line-width=79"
              "--prose-wrap=always"
              "-"
            ];
          };
          auto-format = true;
          language-servers = [
            "typescript-language-server"
            "gpt"
          ];
        }
        {
          name = "awk";
          language-servers = [
            "awk-language-server"
            "gpt"
          ];
        }
        {
          name = "hcl";
          language-servers = [
            "terraform-ls"
            "gpt"
          ];
        }
        {
          name = "tfvars";
          language-servers = [
            "terraform-ls"
            "gpt"
          ];
        }
        {
          name = "cmake";
          language-servers = [
            "cmake-language-server"
            "gpt"
          ];
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "toml";
          language-servers = [
            "taplo"
            "gpt"
          ];
        }
        {
          name = "protobuf";
          language-servers = [
            "bufls"
            "pbkit"
            "gpt"
          ];
        }
        {
          name = "go";
          language-servers = [
            "gopls"
            "golangci-lint-lsp"
            "gpt"
          ];
        }
        {
          name = "gotmpl";
          language-servers = [
            "gopls"
            "gpt"
          ];
        }
        {
          name = "sql";
          scope = "source.sql";
          file-types = [ "sql" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];
    };
  };
}
