return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    config = function()
      vim.keymap.set("n", "<Leader>mp", "<Plug>MarkdownPreview", { desc = "Markdown Preview" })
      vim.keymap.set("n", "<Leader>ms", "<Plug>MarkdownPreviewStop", { desc = "Markdown Preview - Stop" })
      vim.keymap.set("n", "<Leader>mt", "<Plug>MarkdownPreviewToggle", { desc = "Toggle" })
    end,
  },
}
