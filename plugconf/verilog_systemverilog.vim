" let b:verilog_indent_width = 2
" let g:verilog_disable_indent_lst = "eos"

autocmd FileType verilog_systemverilog nnoremap <buffer> <C-]> :VerilogFollowInstance<cr>
autocmd FileType verilog_systemverilog nnoremap <buffer> ,fp :VerilogFollowPort<cr>

" For instantiation in the future
