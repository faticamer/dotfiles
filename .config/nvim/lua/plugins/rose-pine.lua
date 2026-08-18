return {
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

    vim.cmd("colorscheme rose-pine")
  end,
}
