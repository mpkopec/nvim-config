require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'python', 'vhdl', 'markdown', 'markdown_inline', 'yaml', 'json', 'json5', 'jsonc', 'c', 'rust',
  },
  highlight = { enable = true },
})
