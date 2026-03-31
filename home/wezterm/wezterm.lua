-- ============================================================================
-- 🎓 WEZTERM LUA CONFIGURATION - YOUR LUA LEARNING JOURNEY STARTS HERE!
-- ============================================================================
-- Welcome to Lua! This config will teach you Lua step by step.
-- Lua is simple: variables, tables, functions, and that's mostly it!

-- 📚 LUA LESSON 1: IMPORTING MODULES
-- In Lua, we use 'require' to import modules (like 'import' in Python)
-- 'local' creates a variable that's only visible in this file
local wezterm = require 'wezterm'

-- 📚 LUA LESSON 2: TABLES (LIKE OBJECTS/DICTIONARIES)
-- In Lua, almost everything is a table! Tables are like JSON objects.
-- We create an empty table to hold our configuration
local config = {}

-- 📚 LUA LESSON 3: CONDITIONAL LOGIC
-- We can check WezTerm version and adjust accordingly
if wezterm.config_builder then
  -- This is the new way (WezTerm 20220807+)
  config = wezterm.config_builder()
end

-- ============================================================================
-- 🎨 APPEARANCE CONFIGURATION
-- ============================================================================

-- 📚 LUA LESSON 4: ASSIGNING VALUES TO TABLE FIELDS
-- In Lua, we assign values using = (like config.key = value)
-- Strings use single or double quotes (both work the same)
-- config.color_scheme = 'Tomorrow Night'  -- Commented out to use default theme

-- 📚 LUA LESSON 5: NUMBERS AND BOOLEANS
-- Numbers don't need quotes, booleans are true/false (lowercase)
config.font_size = 23.0
config.window_background_opacity = 0.50 -- 65% opacity (35% transparency) - perfect balance
config.macos_window_background_blur = 13 -- Slightly less blur for cleaner look

-- 📚 LUA LESSON 6: CALLING FUNCTIONS
-- Functions are called with parentheses: function_name(arguments)
-- wezterm.font() creates a font object
config.font = wezterm.font('Hack Nerd Font', { weight = 'Regular' })

-- ============================================================================
-- 🪟 WINDOW CONFIGURATION
-- ============================================================================

-- Window decorations (title bar style)
config.window_decorations = "RESIZE"

-- Initial window size
config.initial_cols = 120
config.initial_rows = 40

-- Window padding (space around terminal content)
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- ============================================================================
-- 📑 TAB BAR CONFIGURATION
-- ============================================================================

-- Enable the tab bar
config.enable_tab_bar = true

-- Hide tab bar when only one tab is open
config.hide_tab_bar_if_only_one_tab = true

-- Tab bar position (true = bottom, false = top)
config.tab_bar_at_bottom = true

-- Use fancy tab bar (with rounded corners)
config.use_fancy_tab_bar = true

-- ============================================================================
-- ⌨️  KEYBOARD SHORTCUTS
-- ============================================================================

-- 📚 LUA LESSON 7: ARRAYS/LISTS
-- Arrays in Lua are tables with numeric indices starting at 1 (not 0!)
-- We create an array of key binding tables
config.keys = {
  -- 📚 LUA LESSON 8: TABLE CONSTRUCTORS
  -- Each item in this array is a table with key, mods, and action fields

  -- Tab management (native WezTerm tabs!)
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  -- Pane splitting (native WezTerm splits!)
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Pane navigation
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },

  -- Font size controls
  {
    key = '=',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },

  -- Fullscreen toggle
  {
    key = 'Enter',
    mods = 'CMD',
    action = wezterm.action.ToggleFullScreen,
  },

  -- Copy/Paste (WezTerm handles these automatically, but we can customize)
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'CMD',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  -- Exact case-sensitive search (CMD+F)
  {
    key = 'f',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.Search { CaseSensitiveString = [[]] },
        pane
      )
    end),
  },

  -- Regex search - case-insensitive by default (CMD+SHIFT+F)
  {
    key = 'f',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.Search { Regex = [[]] },
        pane
      )
    end),
  },

  -- Copy last command output (CMD+SHIFT+L)
  -- Copies output from last command, stopping at previous prompt
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      local dims = pane:get_dimensions()
      local cursor_y = dims.scrollback_rows + dims.cursor_y

      local lines = {}
      local found_content = false

      -- Scan upward from cursor, stop at prompt or empty region
      for i = cursor_y - 1, math.max(0, cursor_y - 500), -1 do
        local line = pane:get_lines_as_text(i, i + 1)

        -- Stop if we hit a prompt line (starts with special chars)
        if line and (line:match("^%.%-%(") or line:match("^`%-%->")) then
          break
        end

        -- Collect non-empty lines
        if line and line:match("%S") then
          table.insert(lines, 1, line)
          found_content = true
        elseif found_content and #lines > 5 then
          -- Stop at empty line only after collecting some content
          break
        end
      end

      if #lines > 0 then
        local text = table.concat(lines, "")
        window:copy_to_clipboard(text)
      end
    end),
  },

  -- Word navigation and editing bindings
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendKey { key = 'b', mods = 'ALT' },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendKey { key = 'f', mods = 'ALT' },
  },
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' },
  }
}

-- ============================================================================
-- 🔍 ENHANCED SEARCH MODE (VS CODE-LIKE EXPERIENCE)
-- ============================================================================
--
-- 📖 QUICK SEARCH GUIDE:
--
-- KEYBOARD SHORTCUTS:
--   CMD+F          → Exact search (case-sensitive)
--   CMD+SHIFT+F    → Regex search (case-insensitive)
--   CMD+SHIFT+L    → Copy last command output 🔥
--
-- WHILE SEARCHING:
--   Enter or ↓     → Next match
--   ↑              → Previous match
--   ESC            → Exit search
--
-- 💡 DEVOPS SEARCH EXAMPLES:
--   • Find "error":    CMD+F → type "error"
--   • Find IPs:        CMD+SHIFT+F → "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
--   • Find dates:      CMD+SHIFT+F → "\d{4}-\d{2}-\d{2}"
--   • Find k8s pods:   CMD+F → "pod/"
--   • Find git hashes: CMD+SHIFT+F → "[a-f0-9]{7,40}"
--
-- ============================================================================

-- ============================================================================
-- ⌨️  ENHANCED SEARCH MODE KEY BINDINGS
-- ============================================================================

-- Simple search mode navigation
config.key_tables = {
  search_mode = {
    -- Navigate matches
    { key = 'Enter', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatch' },
    { key = 'DownArrow', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatch' },
    { key = 'UpArrow', mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatch' },

    -- Exit search
    { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
  },
}

-- ============================================================================
-- 🖱️  MOUSE CONFIGURATION
-- ============================================================================

-- Hide mouse cursor when typing
config.hide_mouse_cursor_when_typing = true

-- ============================================================================
-- 🎯 CURSOR CONFIGURATION
-- ============================================================================

-- Enable cursor blinking
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500  -- Blink every 500ms (nice and smooth)

-- ============================================================================
-- 📜 SCROLLBACK CONFIGURATION
-- ============================================================================

-- Number of lines to keep in scrollback
config.scrollback_lines = 1000000

-- ============================================================================
-- 🔔 BELL CONFIGURATION
-- ============================================================================

-- Disable the bell (no annoying sounds!)
config.audible_bell = "Disabled"

-- ============================================================================
-- 🎯 ADVANCED FEATURES
-- ============================================================================

-- Enable hyperlink detection (clickable URLs)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- 📚 LUA LESSON 9: ADDING TO ARRAYS
-- We can add custom hyperlink patterns to the existing ones
table.insert(config.hyperlink_rules, {
  -- Match things that look like git commit hashes
  regex = [[\b[a-f0-9]{6,40}\b]],
  format = 'https://github.com/search?q=$0&type=commits',
})

-- ============================================================================
-- 🎨 CUSTOM COLOR OVERRIDES (OPTIONAL)
-- ============================================================================

-- 📚 LUA LESSON 10: NESTED TABLES
-- We can override specific colors to match our dark theme (like iTerm2)
config.colors = {
  -- Override the tab bar colors for a sleek dark look
  tab_bar = {
    background = '#1e1e1e',  -- Dark background like VS Code
    active_tab = {
      bg_color = '#007acc',   -- Blue accent like VS Code
      fg_color = '#ffffff',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#2d2d30',   -- Subtle dark gray
      fg_color = '#cccccc',
    },
    inactive_tab_hover = {
      bg_color = '#3e3e42',   -- Slightly lighter on hover
      fg_color = '#ffffff',
    },
    new_tab = {
      bg_color = '#1e1e1e',
      fg_color = '#cccccc',
    },
    new_tab_hover = {
      bg_color = '#2d2d30',
      fg_color = '#ffffff',
    },
  },

  -- Enhanced search result highlighting (VS Code-like)
  -- These colors make search matches stand out clearly
  copy_mode_active_highlight_bg = { Color = '#ff79c6' },  -- Pink/magenta background
  copy_mode_active_highlight_fg = { Color = '#000000' },  -- Black text for contrast
  copy_mode_inactive_highlight_bg = { Color = '#ffb86c' }, -- Orange background for other matches
  copy_mode_inactive_highlight_fg = { Color = '#000000' }, -- Black text
}

-- ============================================================================
-- 🚀 PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Enable GPU acceleration
config.front_end = "WebGpu"

-- Optimize for better performance
config.max_fps = 120

-- ============================================================================
-- 🎨 EVENT HANDLERS (Must be registered before returning config!)
-- ============================================================================

-- Visual feedback when searching (displays in status bar)
wezterm.on('update-status', function(window, pane)
  local search_info = ""
  local mode = window:active_key_table()

  if mode == 'search_mode' then
    search_info = wezterm.format({
      { Foreground = { Color = '#ff79c6' } },
      { Text = ' 🔍 SEARCHING ' },
    })
  end

  window:set_right_status(search_info)
end)

-- ============================================================================
-- 🎓 FINAL LUA LESSON: RETURNING VALUES
-- ============================================================================

-- In Lua, the last line of a script can return a value
-- WezTerm expects us to return our configuration table
-- This is how WezTerm gets all our settings!
return config
