" TODO Add folding and divide the file into logical blocks
" Colorscheme handling
set termguicolors

augroup color_overrides
  autocmd!
  autocmd ColorScheme carbonized-dark highlight CursorLine guibg=#3b3b37 gui=underline
  " carbonized-dark predates treesitter's @variable capture, so plain
  " identifiers fall through to Neovim's built-in default link, which
  " resolves to an auto-computed near-white instead of Normal's warm
  " foreground. Re-link it here, alongside the colorscheme it corrects for.
  autocmd ColorScheme carbonized-dark highlight! link @variable Normal

  " gruvbox-material's Type/Structure/StorageClass default to mustard/orange
  " (#d8a657/#e78a4e), the same failure mode that sank everforest and
  " melange for HDL work. Identifier already sits on the palette's one cool
  " teal-blue accent (#7daea3), so re-link the three warm groups onto it
  " rather than hardcoding a duplicate hex.
  autocmd ColorScheme gruvbox-material highlight! link Type Identifier
  autocmd ColorScheme gruvbox-material highlight! link Structure Identifier
  autocmd ColorScheme gruvbox-material highlight! link StorageClass Identifier

  " kanagawa-dragon's stock ColorColumn (theme.ui.bg_p1) collapses back onto
  " Normal's own patched bg (#282727) once ui.bg is overridden above, so the
  " textwidth guide line renders invisible. carbonized-dark's ColorColumn is
  " bg-only and reuses its own CursorLine shade (s:g1); mirror that here with
  " dragonBlack5 (#393836), the shade kanagawa's CursorLine already uses.
  autocmd ColorScheme kanagawa highlight ColorColumn guibg=#393836
augroup END

" colorscheme carbonized-dark
" set background=dark

" --- 2026-08-27 warm-alternative search (Perplexity-assisted): baseline
" carbonized-dark compared against candidates picked to keep Type/
" Structure/StorageClass (VHDL/Verilog's dominant highlight groups) cool
" rather than orange/tan -- the failure mode that sank everforest and
" melange above for HDL work. Three winners kept as toggle options below,
" all scored ~8.5/10 in head-to-head looks against carbonized-dark;
" sonokai was the other real contender but rejected. ---

" candidate 4, WINNER (8.5/10): kanagawa-dragon, background lightened from
" dragonBlack3 (#181616, rejected as too dark on its own) to dragonBlack4
" (#282727) via the plugin's own colors-override table, landing right in
" carbonized/gruvbox-material's darkness range. Type/Structure/StorageClass
" stay cool teal (#8ea4a2), @variable still links to Normal correctly --
" nothing else about Dragon's palette changed, only that one background key.
lua require('kanagawa').setup({ theme = 'dragon', background = { dark = 'dragon' }, colors = { theme = { dragon = { ui = { bg = '#282727' } } } } })
colorscheme kanagawa

" candidate 2, WINNER (8.5/10): gruvbox-material -- a different-enough tone
" from carbonized to be a genuine "change of pace" pick rather than a close
" cousin, unlike candidates 1/4's closer resemblance. Type/Structure/
" StorageClass fixed cool via the augroup override above, though Keyword/
" Statement (#ea6962) still reads warm in keyword-dense VHDL.
" let g:gruvbox_material_background = 'medium'
" colorscheme gruvbox-material

" candidate 1, WINNER (8.5/10): monokai, soda palette as base -- chosen
" over classic/ristretto/pro after iterating on two axes: Type/Structure/
" StorageClass are natively cyan across the whole monokai family (no
" override needed, #8ccdd4 here), and accent saturation is cut ~35% off
" soda's vivid stock (HSL S *= 0.65, computed with python3's colorsys) to
" soften the punch that made stock classic/soda feel too vivid. Normal fg
" is lightened from soda's near-white #f6f6ec to a warm off-white #e7e7da
" (L 0.88, S 0.6x original) rather than dimmed all the way down to
" carbonized's own darker fg, since soda/classic's white is warm-yellow-
" hued and holds up as a believable white at that lightness -- ristretto's
" white was tried first but is inherently pink-hued (near-red HSL hue), so
" any dimming pulled it toward pink instead of gray-neutral and it was
" dropped as a fg-dimming base.
" lua require('monokai').setup({ palette = vim.tbl_extend('force', require('monokai').soda, { white = '#e7e7da', pink = '#c82b68', green = '#8fbf44', aqua = '#8ccdd4', yellow = '#c9c277', orange = '#d38640', purple = '#a37fe3', red = '#c82b68' }) })

" Python3 provider: install.sh provisions hdl-signature (used by the VHDL
" inst: snippet) into an isolated uv tool venv rather than onto whatever
" python3 is first on $PATH, so nvim has to be pointed at that venv's
" pynvim-python wrapper explicitly -- otherwise it silently falls back to
" system python3, which lacks hdl_signature. Guarded on filereadable() so a
" fresh clone that hasn't run install.sh yet still gets nvim's normal
" python3 auto-detection instead of a hard provider failure.
if filereadable(expand('~/.local/bin/pynvim-python'))
  let g:python3_host_prog = expand('~/.local/bin/pynvim-python')
endif

" Filetype plugin
filetype on

" Enable mouse in normal and visual mode. Visual mode is included to fix a
" race condition where a buffered terminal mouse-release event from a
" focus-click is misinterpreted as <Esc>, aborting the visual selection.
" With mouse=nv Neovim properly consumes these events; the <nop> mappings in
" basic-maps.vim neutralise the side-effect of click-to-reposition in visual.
set mouse=nv

" Show line numbers properly
set number
set relativenumber

" Switching between buffers without saving
set hidden

" Taller commandline
set cmdheight=2

" Highlight current line
set cursorline

" Turn on the wild menu
set nowildmenu

" By default, ignore case
set ignorecase

" Makes search act like search in modern browsers
set incsearch

" For regular expressions turn magic on
set magic

" Set line wrapping and its navigation
set nowrap linebreak
set showbreak=…

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=5

" No swap, no backup
set noswapfile
set nobackup

" Open horizontal splits below the current window
set splitbelow

" 1 tab == 2 spaces
" except for the files in which it is overriden in the filetype plugin
set shiftwidth=2
set tabstop=2
set sts=2
set expandtab

" Always show the status line
set laststatus=2

" Show and wrap at 80th column
set colorcolumn=88
set textwidth=88

" Wait for 600ms for the next key in the mapping
set timeoutlen=600

" Formatoptions
set formatoptions-=t
set formatoptions+=cro/qn1j

" Folding
set foldlevel=1
set foldcolumn=2


