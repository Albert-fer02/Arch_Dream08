-- This file contains the configuration for the nvim-tmux-navigation plugin in Neovim.

return {
  -- Plugin: nvim-tmux-navigation
  -- URL: https://github.com/alexghergh/nvim-tmux-navigation
  -- Description: A Neovim plugin that allows seamless navigation between Neovim and tmux panes.
  "alexghergh/nvim-tmux-navigation",
  lazy = false,
  config = function()
    local nvim_tmux_nav = require("nvim-tmux-navigation")
    nvim_tmux_nav.setup({
      disable_when_zoomed = true, -- defaults to false
    })
  end,
}
