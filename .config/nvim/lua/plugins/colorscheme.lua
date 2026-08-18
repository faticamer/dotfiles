return {
  -- Add the theme plugin
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    opts = {
      styles = {
        transparency = true,
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        styles = {
          bold = true,
          italic = true,
          transparency = true, -- Enable transparent background
        },
      })

      -- vim.cmd("colorscheme rose-pine")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
