{ pkgs, ... }:

{
  # Neovim configuration with plugins and language servers (for home-manager)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;
    
    # Neovim configuration
    extraConfig = ''
        " ==============================================================================
        " NEOVIM CONFIGURATION
        " ==============================================================================
        
        " Set leader key to space (important for many plugin keybindings)
        let mapleader = " "
        
        " Basic settings
        set number relativenumber  " Show line numbers (relative + absolute on current line)
        set expandtab             " Use spaces instead of tabs
        set tabstop=2             " Tab width
        set shiftwidth=2          " Indent width
        set softtabstop=2         " Soft tab width
        set smartindent           " Smart auto-indenting
        set wrap                  " Wrap long lines
        set ignorecase            " Ignore case when searching
        set smartcase             " Override ignorecase if search contains uppercase
        set termguicolors         " Enable 24-bit RGB colors
        set scrolloff=8           " Keep 8 lines visible above/below cursor
        set sidescrolloff=8       " Keep 8 columns visible left/right of cursor
        set cursorline            " Highlight current line
        set signcolumn=yes        " Always show sign column (for git/diagnostics)
        set updatetime=50         " Faster completion
        set timeoutlen=300        " Faster key sequence completion
        set clipboard=unnamedplus " Use system clipboard
        set mouse=a               " Enable mouse support
        set splitright            " Open vertical splits to the right
        set splitbelow            " Open horizontal splits below
        set undofile              " Persistent undo
        set undodir=~/.vim/undodir
        set noswapfile            " Disable swap files
        set nobackup              " Disable backup files
        set hidden                " Allow hidden buffers
        set cmdheight=1           " Command line height
        set noshowmode            " Don't show mode (shown in statusline)
        
        " Create undo directory if it doesn't exist
        if !isdirectory(expand("~/.vim/undodir"))
          call mkdir(expand("~/.vim/undodir"), "p")
        endif
        
        " ==============================================================================
        " KEY MAPPINGS
        " ==============================================================================
        
        " Better window navigation
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
        
        " Resize windows with arrows
        nnoremap <C-Up> :resize +2<CR>
        nnoremap <C-Down> :resize -2<CR>
        nnoremap <C-Left> :vertical resize -2<CR>
        nnoremap <C-Right> :vertical resize +2<CR>
        
        " Move text up and down
        vnoremap J :m '>+1<CR>gv=gv
        vnoremap K :m '<-2<CR>gv=gv
        
        " Better indenting
        vnoremap < <gv
        vnoremap > >gv
        
        " Clear search highlighting
        nnoremap <leader>h :nohlsearch<CR>
        
        " Save file
        nnoremap <leader>w :w<CR>
        
        " Quit
        nnoremap <leader>q :q<CR>
        
        " Force quit
        nnoremap <leader>Q :q!<CR>
        
        " Source current file
        nnoremap <leader>x :source %<CR>
        
        " Quick fix list navigation
        nnoremap <leader>j :cnext<CR>
        nnoremap <leader>k :cprev<CR>
        
        " Center cursor when jumping
        nnoremap <C-d> <C-d>zz
        nnoremap <C-u> <C-u>zz
        nnoremap n nzzzv
        nnoremap N Nzzzv
        
        " ==============================================================================
        " LUA CONFIGURATION
        " ==============================================================================
        
        lua << EOF
        -- Neovim Lua configuration
        
        -- ==============================================================================
        -- PLUGIN CONFIGURATIONS
        -- ==============================================================================
        
        -- One Dark theme setup (matches WezTerm's One Dark Vivid)
        require('onedark').setup({
          style = 'dark', -- Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
          transparent = false, -- Show/hide background
          term_colors = true, -- Change terminal color as per the selected theme style
          ending_tildes = false, -- Show the end-of-buffer tildes
          cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
          
          -- toggle theme style ---
          toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
          toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between
          
          -- Change code style ---
          code_style = {
            comments = 'italic',
            keywords = 'bold',
            functions = 'none',
            strings = 'none',
            variables = 'none'
          },
          
          -- Lualine options --
          lualine = {
            transparent = false, -- lualine center bar transparency
          },
          
          -- Custom Highlights --
          colors = {}, -- Override default colors
          highlights = {}, -- Override highlight groups
          
          -- Plugins Config --
          diagnostics = {
            darker = true, -- darker colors for diagnostic
            undercurl = true,   -- use undercurl instead of underline for diagnostics
            background = true,    -- use background color for virtual text
          },
        })
        require('onedark').load()
        
        -- Telescope setup (fuzzy finder)
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        
        telescope.setup{
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
              }
            },
            file_ignore_patterns = { "node_modules", ".git/" },
            layout_config = {
              width = 0.75,
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          pickers = {
            find_files = {
              theme = "dropdown",
              previewer = false,
            },
            live_grep = {
              theme = "dropdown",
            },
          },
        }
        
        -- Telescope keybindings
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
        vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Recent files' })
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
        
        -- NvimTree setup (file explorer)
        require("nvim-tree").setup({
          sort_by = "case_sensitive",
          view = {
            width = 30,
            side = "left",
          },
          renderer = {
            group_empty = true,
            icons = {
              show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
              },
            },
          },
          filters = {
            dotfiles = false,
            custom = { "^.git$" },
          },
          git = {
            enable = true,
            ignore = false,
          },
        })
        
        -- NvimTree keybindings
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
        vim.keymap.set('n', '<leader>o', ':NvimTreeFocus<CR>', { desc = 'Focus file explorer' })
        
        -- Treesitter setup (better syntax highlighting)
        -- Parsers are provided via nvim-treesitter.withPlugins in Nix.
        -- Guard with pcall so Neovim still starts when treesitter isn't on rtp (e.g. Cursor's embedded nvim).
        local ok_ts, _ = pcall(require, 'nvim-treesitter.configs')
        if ok_ts then
          require('nvim-treesitter.configs').setup({
            -- Don't use ensure_installed or auto_install with Nix (read-only store)
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = {
              enable = true,
            },
          })
        end
        
        -- LSP Configuration using new vim.lsp.config API (nvim 0.11+)
        
        -- Global LSP keybindings
        vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, { desc = 'Open diagnostics' })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
        vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
        
        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          local opts = { buffer = bufnr }
          
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
          vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Add workspace folder' }))
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Remove workspace folder' }))
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, vim.tbl_extend('force', opts, { desc = 'List workspace folders' }))
          vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Type definition' }))
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename' }))
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'References' }))
          vim.keymap.set('n', '<leader>lf', function()
            vim.lsp.buf.format { async = true }
          end, vim.tbl_extend('force', opts, { desc = 'Format' }))
        end
        
        -- Default capabilities with completion support
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        
        -- Setup language servers using new vim.lsp.config API
        
        -- Python LSP
        vim.lsp.config.pyright = {
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
          on_attach = on_attach,
          capabilities = capabilities,
        }
        
        -- Go LSP
        vim.lsp.config.gopls = {
          cmd = { 'gopls' },
          filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        }
        
        -- Bash LSP
        vim.lsp.config.bashls = {
          cmd = { 'bash-language-server', 'start' },
          filetypes = { 'sh', 'bash' },
          on_attach = on_attach,
          capabilities = capabilities,
        }
        
        -- Lua LSP (for Neovim config)
        vim.lsp.config.lua_ls = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
              },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        }
        
        -- YAML LSP
        vim.lsp.config.yamlls = {
          cmd = { 'yaml-language-server', '--stdio' },
          filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
          on_attach = on_attach,
          capabilities = capabilities,
        }
        
        -- JSON LSP
        vim.lsp.config.jsonls = {
          cmd = { 'vscode-json-language-server', '--stdio' },
          filetypes = { 'json', 'jsonc' },
          on_attach = on_attach,
          capabilities = capabilities,
        }
        
        -- Autocompletion setup with nvim-cmp
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        
        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
          }),
        })
        
        -- Setup lualine (status bar)
        require('lualine').setup({
          options = {
            theme = 'onedark',
            icons_enabled = true,
            component_separators = { left = "|", right = "|"},
            section_separators = { left = "", right = ""},
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
        })
        
        -- Gitsigns setup (git integration)
        require('gitsigns').setup({
          signs = {
            add          = { text = '│' },
            change       = { text = '│' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signcolumn = true,
          numhl = false,
          linehl = false,
          word_diff = false,
          watch_gitdir = {
            interval = 1000,
            follow_files = true
          },
          attach_to_untracked = true,
          current_line_blame = false,
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol',
            delay = 1000,
            ignore_whitespace = false,
          },
          sign_priority = 6,
          update_debounce = 100,
          status_formatter = nil,
          max_file_length = 40000,
          preview_config = {
            border = 'single',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
          },
        })
        
        -- Comment.nvim setup (easy commenting)
        require('Comment').setup({
          padding = true,
          sticky = true,
          toggler = {
            line = 'gcc',
            block = 'gbc',
          },
          opleader = {
            line = 'gc',
            block = 'gb',
          },
        })
        
        -- Which-key setup (shows keybindings)
        require("which-key").setup({
          plugins = {
            marks = true,
            registers = true,
            spelling = {
              enabled = true,
              suggestions = 20,
            },
          },
          win = {  -- Changed from 'window' to 'win' (new API)
            border = "rounded",
            position = "bottom",
            margin = { 1, 0, 1, 0 },
            padding = { 2, 2, 2, 2 },
          },
          layout = {
            height = { min = 4, max = 25 },
            width = { min = 20, max = 50 },
            spacing = 3,
            align = "left",
          },
        })
        
        -- Register which-key mappings using new spec format
        local wk = require("which-key")
        wk.add({
          { "<leader>f", group = "Find" },
          { "<leader>ff", desc = "Find files" },
          { "<leader>fg", desc = "Live grep" },
          { "<leader>fb", desc = "Find buffers" },
          { "<leader>fh", desc = "Help tags" },
          { "<leader>fo", desc = "Recent files" },
          { "<leader>fw", desc = "Find word" },
          
          { "<leader>l", group = "LSP" },
          { "<leader>ld", desc = "Open diagnostics" },
          { "<leader>lq", desc = "Diagnostics to loclist" },
          { "<leader>lf", desc = "Format" },
          
          { "<leader>w", group = "Workspace" },
          { "<leader>wa", desc = "Add folder" },
          { "<leader>wr", desc = "Remove folder" },
          { "<leader>wl", desc = "List folders" },
          
          { "<leader>c", group = "Code" },
          { "<leader>ca", desc = "Code action" },
          
          { "<leader>r", group = "Refactor" },
          { "<leader>rn", desc = "Rename" },
          
          { "<leader>e", desc = "Toggle explorer" },
          { "<leader>o", desc = "Focus explorer" },
          { "<leader>h", desc = "Clear search" },
          { "<leader>q", desc = "Quit" },
          { "<leader>Q", desc = "Force quit" },
          { "<leader>x", desc = "Source file" },
        })
        
        EOF
    '';
    
    # Plugins
    plugins = with pkgs.vimPlugins; [
      # Theme
      onedark-nvim
      
      # Status line
      lualine-nvim
      
      # File explorer
      nvim-tree-lua
      nvim-web-devicons
      
      # Fuzzy finder
      telescope-nvim
      plenary-nvim
      
      # Syntax highlighting (withPlugins; withAllGrammars was removed/changed in recent nixpkgs)
      (nvim-treesitter.withPlugins (p: [
        p.python p.lua p.go p.bash p.json p.yaml p.markdown p.vim p.nix
        p.javascript p.typescript p.html p.css p.toml p.dockerfile
      ]))
      
      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      
      # Git integration
      gitsigns-nvim
      
      # Quality of life
      comment-nvim
      which-key-nvim
      vim-surround
      nvim-autopairs
    ];
  };
}
