{ pkgs, ... }:

{
  # Neovim configuration with plugins and language servers (for home-manager)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
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
        
        -- Tokyo Night theme setup
        require("tokyonight").setup({
          style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
          light_style = "day", -- The theme is used when the background is set to light
          transparent = false, -- Enable this to disable setting the background color
          terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = {},
            variables = {},
            sidebars = "dark", -- style for sidebars, see below
            floats = "dark", -- style for floating windows
          },
          sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows
          day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style
          hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead
          dim_inactive = false, -- dims inactive windows
          lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
        })
        vim.cmd([[colorscheme tokyonight]])
        
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
        -- Note: We use nvim-treesitter.withAllGrammars from Nix, so parsers are pre-installed
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
        
        -- LSP Configuration
        local lspconfig = require('lspconfig')
        
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
        
        -- Setup language servers
        
        -- Python LSP
        lspconfig.pyright.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })
        
        -- Go LSP
        lspconfig.gopls.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        })
        
        -- Bash LSP
        lspconfig.bashls.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })
        
        -- Lua LSP (for Neovim config)
        lspconfig.lua_ls.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
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
        })
        
        -- YAML LSP
        lspconfig.yamlls.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })
        
        -- JSON LSP
        lspconfig.jsonls.setup({
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })
        
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
            theme = 'tokyonight',
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
      tokyonight-nvim
      
      # Status line
      lualine-nvim
      
      # File explorer
      nvim-tree-lua
      nvim-web-devicons
      
      # Fuzzy finder
      telescope-nvim
      plenary-nvim
      
      # Syntax highlighting
      nvim-treesitter.withAllGrammars
      
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
