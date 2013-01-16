if exists('g:loaded_owl')
  finish
endif
let g:loaded_owl = 1

let s:save_cpo = &cpo
set cpo&vim


command! -nargs=*
\	OwlCheck
\	call owl#check({
\		"expr" : <q-args>,
\		"local" : chained#is_function_cope() ? l: : {},
\		"line" : expand("<slnum>"),
\		"filename" : chained#is_function_cope() ? "" : expand("<sfile>"),
\	})

command! -nargs=*
\	OwlEqual
\	call owl#equal({
\		"expr" : <q-args>,
\		"local" : chained#is_function_cope() ? l: : {},
\		"line" : expand("<slnum>"),
\		"filename" : chained#is_function_cope() ? "" : expand("<sfile>"),
\	})

command! -nargs=*
\	OwlThrow
\	call owl#throw({
\		"expr" : <q-args>,
\		"local" : chained#is_function_cope() ? l: : {},
\		"line" : expand("<slnum>"),
\		"filename" : chained#is_function_cope() ? "" : expand("<sfile>"),
\	})





let &cpo = s:save_cpo
unlet s:save_cpo
