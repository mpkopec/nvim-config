" let b:verilog_indent_width = 2
" let g:verilog_disable_indent_lst = "eos"

autocmd FileType verilog_systemverilog nnoremap <buffer> ,fi :VerilogFollowInstance<cr>
autocmd FileType verilog_systemverilog nnoremap <buffer> ,fp :VerilogFollowPort<cr>

autocmd FileType verilog_systemverilog setl commentstring=//\ %s

" For instantiation in the future
" For automatic parameter assignment to declaration:
" '<,'>s/\.\(\w\+\)(\(\("\w\+"\)\|\d[.0-9]*\))/parameter \1 = \2/

autocmd BufEnter *.v set filetype=verilog_systemverilog
autocmd BufEnter *.v set shiftwidth=2
autocmd BufEnter *.sv set filetype=verilog_systemverilog
autocmd BufEnter *.sv set shiftwidth=2
