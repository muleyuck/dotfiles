local wezterm = require 'wezterm'

local function BaseName(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on(
  'format-window-title', 
  function(tab)
    return BaseName(tab.active_pane.foreground_process_name)
 end
)

wezterm.on(
  'format-tab-title', 
  function(tab, tabs, panes, config, hover, max_width)
    local index = tab.tab_index + 1
    local pane = tab.active_pane
    local zoomed = tab.active_pane.is_zoomed and '🔎 ' or ' '

    local cwd = BaseName(pane.current_working_dir.path)
    local process_name = BaseName(pane.foreground_process_name)
    local title = index .. ": " .. cwd .. " | " .. process_name

    return {
      { Text = " " .. title .. " " },
    }

  end
)
