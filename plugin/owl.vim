" if exists('g:loaded_owl')
"   finish
" endif
" let g:loaded_owl = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=* OwlLetOption
\	execute "let ".[<f-args>][0]."=".
\		get(chained#is_function_cope() ? extend(copy(g:), l:) : g:, [<f-args>][1], get([<f-args>], 2))


command! -nargs=*
\	OwlErrorMessage
\	if exists("l:")
\|		if !has_key(l:, "owl_local_is_failed")
\| 			echo "in function ".chained#this_func()
\|		endif
\|		let owl_local_is_failed = 1
\|		echo owl#error_message(expand("<slnum>"), <q-args>)
\|	else
\|		echo owl#error_message_global(expand("<slnum>"), <q-args>, expand("<sfile>"))
\|	endif


function! s:to_SNR(SID)
	return "<SNR>".a:SID."_"
endfunction


command! -nargs=*
\	OwlCheck
\	OwlLetOption __owl_SID owl_SID chained#SID()
\|	if !eval(chained#script_function_to_function_symbol(<q-args>,  s:to_SNR(__owl_SID)))
\|		execute "OwlErrorMessage" <q-args>
\|	endif
\|	unlet __owl_SID

command! -nargs=1 OwlCheckNot OwlCheck !(<args>)


command! -nargs=1 OwlEqual execute "OwlCheck" join(eval("[".chained#script_function_to_function_symbol(<q-args>, chained#SNR())."]")," == ")


function! s:exception_id(exception)
	return matchstr(a:exception, '\zsE\d*\ze:.*')
endfunction

" function! s:owl_throw_expr(q_args)
" 	return matchstr(a:q_args, '\zs.*\ze,\s*.*')
" endfunction


command! -nargs=*
\	OwlThrow
\	try
\|		call eval(chained#script_function_to_function_symbol(matchstr(<q-args>, '\zs.*\ze,\s*.*'), chained#SNR()))
\|	catch
\|		if s:exception_id(v:exception) !=# matchstr(<q-args>, '.*,\s*\zs.*\ze')
\|			execute "OwlErrorMessage" <q-args>
\|		endif
\|	endtry



let &cpo = s:save_cpo
unlet s:save_cpo
