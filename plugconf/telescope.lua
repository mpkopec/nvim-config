vim.keymap.set("n", ",t",  ":Telescope<CR>")
vim.keymap.set("n", ",tt",  ":Telescope tags<CR>")

-- Two-stage tag browser: pick a kind (function, variable, ...) from the kinds
-- actually present in the project's tags file, then reopen the standard tags
-- picker pre-filtered to that kind. Telescope's own `tags` picker shows a kind
-- column but excludes it from the fuzzy-match ordinal, so it cannot be
-- searched on directly (see telescope/make_entry.lua:gen_from_ctags); this
-- works around that by pre-filtering the tag lines ourselves before handing
-- them to the stock picker's entry_maker/previewer/jump logic.
local function tags_by_kind()
  local builtin = require("telescope.builtin")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local tagfiles = vim.fn.tagfiles()
  if vim.tbl_isempty(tagfiles) then
    vim.notify("No tags file found. Create one with ctags -R", vim.log.levels.ERROR)
    return
  end
  for i, f in ipairs(tagfiles) do
    tagfiles[i] = vim.fn.expand(f, true)
  end

  local all_lines = {}
  local kind_counts = {}
  for _, tagfile in ipairs(tagfiles) do
    for _, line in ipairs(vim.fn.readfile(tagfile)) do
      if line ~= "" and line:sub(1, 1) ~= "!" then
        table.insert(all_lines, line)
        local kind = line:match("\tkind:([^\t]+)")
        if kind then
          kind_counts[kind] = (kind_counts[kind] or 0) + 1
        end
      end
    end
  end

  if vim.tbl_isempty(kind_counts) then
    vim.notify(
      "No kind info in tags file. Requires --fields=+K in g:gutentags_ctags_extra_args and a regenerated tags file.",
      vim.log.levels.ERROR
    )
    return
  end

  local kinds = {}
  for kind, count in pairs(kind_counts) do
    table.insert(kinds, { kind = kind, count = count })
  end
  table.sort(kinds, function(a, b) return a.kind < b.kind end)

  pickers.new({}, {
    prompt_title = "Tag Kinds",
    finder = finders.new_table {
      results = kinds,
      entry_maker = function(item)
        return {
          value = item.kind,
          display = string.format("%-20s %d", item.kind, item.count),
          ordinal = item.kind,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not selection then
          return
        end

        local filtered = {}
        for _, line in ipairs(all_lines) do
          if line:match("\tkind:([^\t]+)") == selection.value then
            table.insert(filtered, line)
          end
        end

        local tmp = vim.fn.tempname()
        vim.fn.writefile(filtered, tmp)
        builtin.tags { ctags_file = tmp, prompt_title = "Tags [" .. selection.value .. "]" }
        -- the stock picker reads the file asynchronously via `cat`; deleting
        -- immediately would race the read, so defer the cleanup instead.
        vim.defer_fn(function() os.remove(tmp) end, 3000)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", ",tk", tags_by_kind)
vim.keymap.set("n", ",tr",  ":Telescope registers<CR>")
vim.keymap.set("n", ",tb",  ":Telescope buffers<CR>")
vim.keymap.set("n", ",tch",  ":Telescope command_history<CR>")
vim.keymap.set("n", ",tgc",  ":Telescope git_commits<CR>")
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")

require('telescope').load_extension('fzf')

-- You don't need to set any of these options.
-- IMPORTANT!: this is only a showcase of how you can set default options!
local fb_actions = require "telescope".extensions.file_browser.actions
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<C-k>"] = false,
        ["<C-f>"] = false,
        ["<C-j>"] = "preview_scrolling_down",
        ["<C-k>"] = "preview_scrolling_up",
        ["<C-h>"] = "preview_scrolling_left",
        ["<C-l>"] = "preview_scrolling_right",
      }
    }
  },
  extensions = {
    file_browser = {
      -- disables netrw and use telescope-file-browser in its place
      -- hijack_netrw = true,
      mappings = {
        ["i"] = {
          -- your custom insert mode mappings
        },
        ["n"] = {
          -- your custom normal mode mappings
          -- ["l"] = fb_actions.open,
          ["h"] = fb_actions.goto_parent_dir,
          ["H"] = fb_actions.toggle_hidden,
        },
      },
    },
  },
}
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require('telescope').load_extension('file_browser')

vim.keymap.set("n", ",tf", ":Telescope file_browser<CR>")

