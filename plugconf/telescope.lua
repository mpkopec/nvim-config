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

-- Browse-and-insert helper for the `inst:`/`comp:` snippet triggers: picks
-- a VHDL entity from ctags (kind "entity" — long-form kind names, since
-- gutentags is configured with --fields=+K) and inserts just the bare
-- entity name at the cursor, not a full trigger — the caller types
-- `inst:`/`comp:` themselves first, so this picker only fills in the part
-- that benefits from fuzzy search. Disambiguation between multiple
-- declarations of the same entity name happens later, at snippet-expand
-- time (see UltiSnips/vhdl.snippets' resolve_entity_signature()), not here.
local function insert_entity_name()
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

  local entities = {}
  local seen = {}
  for _, f in ipairs(tagfiles) do
    for _, line in ipairs(vim.fn.readfile(vim.fn.expand(f, true))) do
      if line ~= "" and line:sub(1, 1) ~= "!" then
        if line:match("\tkind:([^\t]+)") == "entity" then
          local name = line:match("^([^\t]+)")
          if name and not seen[name] then
            seen[name] = true
            table.insert(entities, name)
          end
        end
      end
    end
  end

  if vim.tbl_isempty(entities) then
    vim.notify("No VHDL entities found in tags.", vim.log.levels.ERROR)
    return
  end
  table.sort(entities)

  pickers.new({}, {
    prompt_title = "VHDL Entity",
    finder = finders.new_table { results = entities },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not selection then
          return
        end
        vim.api.nvim_put({ selection[1] }, "c", true, true)
        vim.cmd("startinsert!")
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", ",tm", insert_entity_name)
vim.keymap.set("i", "<C-t>m", insert_entity_name)

-- Reference-panel helper: browse VHDL entities / Verilog+SystemVerilog
-- modules (ctags kinds "entity" and "module" — both confirmed via a scratch
-- `ctags --fields=+K` run to emit the same long-form kind shape) and, on
-- <CR>, render just that declaration's interface into a persistent scratch
-- buffer instead of jumping into the real file. Live preview while browsing
-- still shows the real source (top_aligned_ctags_previewer below), since
-- that's free — it's the <CR> commit step that pays for an actual
-- hdl-signature parse, mirroring the existing split between cheap
-- ctags-based discovery and parsing reserved for the one entity actually
-- picked (same principle behind ,tm/inst:/comp:).
if vim.fn.has("python3") == 1 then
  vim.cmd([[
py3 << EOF
def _hdl_signature_render_declaration(path, name):
    # Reads from disk (parse_file), not any open buffer, matching
    # resolve_entity_signature()'s precedent in UltiSnips/vhdl.snippets —
    # unsaved edits in an open buffer are not reflected here.
    from hdl_signature import parse_file, render_declaration
    try:
        signatures = [s for s in parse_file(path) if s.name == name]
    except Exception as e:
        return {"ok": False, "error": str(e)}
    if not signatures:
        return {"ok": False, "error": "%s not found in %s" % (name, path)}
    try:
        text = render_declaration(signatures[0], keyword="entity")
    except NotImplementedError as e:
        return {"ok": False, "error": str(e)}
    return {"ok": True, "text": text, "language": signatures[0].language.value}
EOF
  ]])
end

-- One reused scratch buffer rather than a new split per invocation, per the
-- "replace in place" behavior settled on for this feature.
local interface_bufnr = nil

local function show_interface_panel(name, text, language)
  local lines = vim.split(text, "\n", { plain = true })

  if not (interface_bufnr and vim.api.nvim_buf_is_valid(interface_bufnr)) then
    interface_bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[interface_bufnr].buftype = "nofile"
    vim.bo[interface_bufnr].bufhidden = "hide"
    vim.bo[interface_bufnr].swapfile = false
  end

  vim.bo[interface_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(interface_bufnr, 0, -1, false, lines)
  vim.bo[interface_bufnr].modifiable = false
  vim.bo[interface_bufnr].filetype = language
  pcall(vim.api.nvim_buf_set_name, interface_bufnr, "hdl-interface://" .. name)

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, #l)
  end
  width = math.min(width + 2, 60)

  local win = nil
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == interface_bufnr then
      win = w
      break
    end
  end

  if win then
    vim.api.nvim_win_set_width(win, width)
  else
    vim.cmd("leftabove vertical sbuffer " .. interface_bufnr)
    vim.api.nvim_win_set_width(0, width)
  end
end

local function show_hdl_interface(path, name)
  if vim.fn.has("python3") == 0 then
    vim.notify("python3 provider not available.", vim.log.levels.ERROR)
    return
  end
  -- json_encode doubles as a Python string-literal encoder here (JSON's
  -- double-quoted escaping is valid Python syntax), avoiding a hand-rolled
  -- escaper for path/name going into the py3eval expression string.
  local ok, result = pcall(vim.fn.py3eval, string.format(
    "_hdl_signature_render_declaration(%s, %s)",
    vim.fn.json_encode(path),
    vim.fn.json_encode(name)
  ))
  if not ok then
    vim.notify("Failed to query hdl-signature: " .. tostring(result), vim.log.levels.ERROR)
    return
  end
  if not result.ok then
    vim.notify(result.error, vim.log.levels.WARN)
    return
  end
  show_interface_panel(name, result.text, result.language)
end

-- Stock previewers.ctags (telescope/previewers/buffer_previewer.lua) always
-- centers the jumped-to line (`norm! zz`) and offers no alignment option —
-- confirmed by reading its source, not guessed — so top-aligning requires
-- reimplementing its jump logic rather than configuring it. Standard ctags
-- entries carry no line number field (--fields=+n isn't set), only a search
-- pattern (`scode`); telescope's own gen_from_ctags leaves entry.lnum at a
-- useless 1 for this format and instead jumps via vim.fn.search(scode) —
-- mirrored here rather than reinvented, since it's already the correct
-- mechanism for this tag format.
local function top_aligned_ctags_previewer()
  local previewers = require("telescope.previewers")
  local conf = require("telescope.config").values

  local function jump(self, entry)
    if entry.scode then
      local scode = entry.scode:gsub([[\/]], "/"):gsub("[%]~*]", function(x)
        return "\\" .. x
      end)
      pcall(vim.fn.matchdelete, self.state.hl_id, self.state.winid)
      vim.cmd("keepjumps norm! gg")
      vim.fn.search(scode, "W")
      vim.cmd("norm! zt")
      self.state.hl_id = vim.fn.matchadd("TelescopePreviewMatch", scode)
    end
  end

  return previewers.new_buffer_previewer({
    title = "HDL Interface Preview",
    teardown = function(self)
      if self.state and self.state.hl_id then
        pcall(vim.fn.matchdelete, self.state.hl_id, self.state.hl_win)
        self.state.hl_id = nil
      end
    end,
    get_buffer_by_name = function(_, entry)
      return entry.filename
    end,
    define_preview = function(self, entry)
      conf.buffer_previewer_maker(entry.filename, self.state.bufnr, {
        bufname = self.state.bufname,
        winid = self.state.winid,
        callback = function(bufnr)
          pcall(vim.api.nvim_buf_call, bufnr, function()
            jump(self, entry)
          end)
        end,
      })
    end,
  })
end

local function view_hdl_interface()
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

  local results = {}
  for _, f in ipairs(tagfiles) do
    for _, line in ipairs(vim.fn.readfile(vim.fn.expand(f, true))) do
      if line ~= "" and line:sub(1, 1) ~= "!" then
        local kind = line:match("\tkind:([^\t]+)")
        if kind == "entity" or kind == "module" then
          local tag, file, scode = line:match('([^\t]+)\t([^\t]+)\t/^?\t?(.*)/;"')
          if tag and file then
            table.insert(results, {
              tag = tag,
              filename = vim.fn.fnamemodify(file, ":p"),
              scode = scode,
            })
          end
        end
      end
    end
  end

  if vim.tbl_isempty(results) then
    vim.notify("No VHDL entities or Verilog/SystemVerilog modules found in tags.", vim.log.levels.ERROR)
    return
  end

  pickers.new({}, {
    prompt_title = "HDL Interface",
    finder = finders.new_table {
      results = results,
      entry_maker = function(item)
        return {
          value = item,
          display = string.format("%-30s %s", item.tag, vim.fn.fnamemodify(item.filename, ":~:.")),
          ordinal = item.tag .. " " .. item.filename,
          filename = item.filename,
          scode = item.scode,
          lnum = 1,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    previewer = top_aligned_ctags_previewer(),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not selection then
          return
        end
        show_hdl_interface(selection.value.filename, selection.value.tag)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", ",tv", view_hdl_interface)

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

