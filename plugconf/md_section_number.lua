require("md_section_number").setup({
    max_level = 4, -- stop to add section number after max_level
    min_level = 2, -- start to add section number after min_level
    ignore_pairs = { -- the markdown content in these pairs will be ignored
      { "```", "```" },
      { "\\~\\~\\~", "\\~\\~\\~" },
      { "<!--", "-->" },
    },
    toc = { -- toc sidebar config
      width = 50,
      position = "right",
      indent_space_number = 2,
      header_prefix = "- ",
    },
  })

vim.keymap.set("n", ",mdu",  ":MdUpdateNumber<CR>")
vim.keymap.set("n", ",mdj",  ":MdHeaderDecrease<CR>")
vim.keymap.set("n", ",mdk",  ":MdHeaderIncrease<CR>")
vim.keymap.set("n", ",mdc",  ":MdClearNumber<CR>")
vim.keymap.set("n", ",mds",  ":MdTocToggle<CR>")
