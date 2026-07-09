let g:gutentags_cache_dir="~/.cache"
let g:gutentags_ctags_extra_args = ['--languages=Verilog,SystemVerilog,VHDL,Python,C,Tcl,Tex,Vim,Lua', '--fields=+zK']
let g:gutentags_file_list_command = {
      \ 'markers': {
      \   '.git': 'git ls-files --recurse-submodules',
      \ },
      \ }
