scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:to_slash_path(path)
	return substitute(a:path, '\\', '/', 'g')
endfunction

function! s:parse_scriptname(src)
	return substitute(a:src, '\s*\(\d*\)\s*:\s*\(.*\)', '\=submatch(1). ":" . string(s:to_slash_path(submatch(2))) ', "g")
endfunction


function! s:function()
	BudouSilentBegin
	redir =>flist
	silent function
	redir END
	BudouSilentEnd
	return split(flist, "\n")
endfunction


function! s:scriptnames()
	BudouSilentBegin
	redir =>slist
	silent scriptnames
	redir END
	BudouSilentEnd
	return eval("{" . join(map(split(slist, "\n"), "s:parse_scriptname(v:val)"), ","). "}")
endfunction


function! s:key(dict, item, ...)
	let op      = get(a:, 1, "==")
	let default = get(a:, 2, 0)
	return get(keys(filter(copy(a:dict), "v:val ". op ." a:item")), 0, default)
endfunction


function! s:filename(SID, ...)
	let scriptnames = get(a:, 1, s:scriptnames())
	return get(scriptnames, a:SID, "")
endfunction


function! s:SID(filename, ...)
	let scriptnames = get(a:, 1, s:scriptnames())
	return s:key(scriptnames, a:filename)
endfunction


function! s:to_fileline(filename, funcname, slnum)
	if !filereadable(a:filename)
		return a:slnum
	endif
	return get(filter(map(readfile(a:filename), "v:val =~ '.*'.a:funcname ? v:key + a:slnum  + 1: -1"), "v:val != -1"), 0, -1)
endfunction


function! owl#error_message(slnum, q_args)
	let SNR = chained#called_func(1)
	let SID =  chained#to_SID(SNR)
	let funcname = chained#to_function_name(SNR)
	let filename = s:filename(SID)
	
	return filename . ":" . s:to_fileline(filename, "s:".funcname, a:slnum) . ":" . "[failure] ".a:q_args
endfunction


function! owl#error_message_global(slnum, q_args, filename)
	let filename = a:filename
	let fileline = a:slnum
	return filename . ":" . fileline . ":" . "failure[ ". a:q_args . " ]"
endfunction


function! owl#run(filename)
	let SID = s:SID(s:to_slash_path(a:filename))
	let flist = filter(s:function(), "chained#to_SID(v:val) == SID && chained#to_function_name(v:val) =~ 'test_.*'")
" 	PP flist
	for func in flist
		call eval(matchstr(func, "function \\zs.*\\ze"))
	endfor
endfunction


function! owl#filename_to_SID(filename)
	return s:key(s:scriptnames(), ".*".a:filename, "=~")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

finish


" echo expand("<sfile>")

function! s:main()
	let test = "C:/vim/vim73-kaoriya-win32/vim73/ftplugin.vim"
	echo s:key(s:scriptnames(), ".*autoload/owl.vim", "=~")
	echo s:SID("autoload/owl.vim")
	echo PP(s:scriptnames())
endfunction
call s:main()



