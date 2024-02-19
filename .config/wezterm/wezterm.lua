local wezterm = require 'wezterm'

return {
  color_scheme = "kanagawabones",
  font = wezterm.font("Berkeley Mono"),
  font_size = 16,
  window_background_opacity = 0.95,
  macos_window_background_blur = 30,
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  window_decorations = "RESIZE",
}
