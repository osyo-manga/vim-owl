scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:to_slash_path(path)
	return substitute(a:path, '\\', '/', 'g')
endfunction

function! s:parse_scriptname(src)
	return substitute(a:src, '\s*\(\d*\)\s*:\s*\(.*\)', '\=submatch(1). ":" . string(s:to_slash_path(expand(submatch(2)))) ', "g")
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


let s:filename_cache = {}
function! s:filename(SID, ...)
	if !get(s:filename_cache, a:SID, 0)
		let scriptnames = get(a:, 1, s:scriptnames())
		let s:filename_cache[a:SID] = get(scriptnames, a:SID, "")
	endif
	return get(s:filename_cache, a:SID)
endfunction


let s:SID_cache = {}
function! s:SID(filename, ...)
	if !get(s:SID_cache, a:filename, 0)
		let scriptnames = get(a:, 1, s:scriptnames())
		let s:SID_cache[a:filename] = s:key(scriptnames, a:filename)
	endif
	return get(s:SID_cache, a:filename)
endfunction


function! s:to_fileline(filename, funcname, slnum)
	if !filereadable(a:filename)
		return a:slnum
	endif
	return get(filter(map(readfile(a:filename), "v:val =~ '.*'.a:funcname ? v:key + a:slnum  + 1: -1"), "v:val != -1"), 0, -1)
endfunction


function! owl#run(filename)
	let filename = s:to_slash_path(fnamemodify(a:filename, ":p"))
	if !filereadable(filename)
		echo "Not read file ".filename
		return
	endif

	try
		execute "so" filename
	catch /.*/
		echoerr v:exception
		return
	endtry

	let SID = s:SID(filename)
	let flist = filter(s:function(), "chained#to_SID(v:val) == SID && chained#to_function_name(v:val) =~ 'test_.*'")

	let begin_func = "<SNR>".SID."_owl_begin"
	if exists("*".begin_func)
		call eval(begin_func."()")
	endif

	for func in flist
		call eval(matchstr(func, "function \\zs.*\\ze"))
	endfor

	let end_func = "<SNR>".SID."_owl_end"
	if exists("*".end_func)
		call eval(end_func."()")
	endif
endfunction


function! owl#run_function(filename, funcname)
	let filename = s:to_slash_path(fnamemodify(a:filename, ":p"))
	if !filereadable(filename)
		echo "Not read file ".filename
		return
	endif

	try
		execute "so" filename
	catch /.*/
		echoerr v:exception
		return
	endtry

	let SID = s:SID(filename)
	let begin_func = "<SNR>".SID."_owl_begin"
	if exists("*".begin_func)
		call eval(begin_func."()")
	endif

	call eval(chained#script_function_to_function_symbol(a:funcname."()", s:to_SNR(SID)))

	let end_func = "<SNR>".SID."_owl_end"
	if exists("*".end_func)
		call eval(end_func."()")
	endif
endfunction


function! owl#filename_to_SID(filename)
	return s:key(s:scriptnames(), ".*".a:filename, "=~")
endfunction


function! s:to_SNR(SID)
	return "<SNR>".a:SID."_"
endfunction


function! s:get_option(context, op, ...)
 	let default = get(a:, 1, get(g:, "owl_".a:op, ""))
	return get(a:context, a:op, get(get(a:context, "local", {}), "owl_".a:op, default))
endfunction


function! s:eval(expr, local, SID)
	call extend(l:, a:local)
	return eval(chained#script_function_to_function_symbol(a:expr, s:to_SNR(a:SID)))
endfunction


function! s:print_message(format, file, line, expr, msg)
	let rule = {
\		"f" : a:file,
\		"l" : a:line,
\		"e" : a:expr,
\		"m" : a:msg
\	}

	let result = a:format
	let result = substitute(result, '%%', 'owl_parsent_symbol', "g")
	for symbol in keys(rule)
		let result = substitute(result, '%'. symbol, rule[symbol], "g")
	endfor
	let result = substitute(result, 'owl_parsent_symbol', '%', "g")
	return result
endfunction


function! s:message(context)
	let type = (a:context.type == "F" ? "failure" : "success")
	let line = get(a:context, "line", 0)
	let msg  = get(a:context, "message", "")
	let expr = a:context.expr
	let func_symbol = chained#latest_called_script_function(chained#call_stack()[:-2])

	let format = s:get_option(a:context, type."_message_format", "%f:%l:%m %e")
	if !empty(format)
		if empty(func_symbol)
			echo s:print_message(format, get(a:context, "filename", " "), line, expr, msg)
		else
			let SID =  chained#to_SID(func_symbol)
			let funcname = chained#to_function_name(func_symbol)
			let filename = s:filename(SID)

			echo s:print_message(format, filename, s:to_fileline(filename, "s:".funcname, line), expr, msg)
		endif
	endif
endfunction


function! owl#check(context)
	let SID = s:get_option(a:context, "SID", chained#to_SID(chained#latest_called_script_function()))
	if s:eval(a:context.expr, get(a:context, "local", {}), SID)
		call s:message(extend({ "type" : "S" }, a:context))
	else
		call s:message(extend({ "type" : "F" }, a:context))
	endif
endfunction


function! s:eval_op(context, op)
	let SID = s:get_option(a:context, "SID", chained#to_SID(chained#latest_called_script_function(chained#call_stack()[:-2])))
	return join(map(s:eval("[".a:context.expr."]", get(a:context, "local", {}), SID), "string(v:val)"), " ".a:op." ")
endfunction

function! owl#equal(context)
	let expr = s:eval_op(a:context, "==")
	return owl#check(extend({ "expr" : expr }, a:context, "keep"))
endfunction


function! s:exception_id(exception)
	return matchstr(a:exception, '\zsE\d*\ze:.*')
endfunction


function! owl#throw(context)
	let expr = matchstr(a:context.expr, '\zs.*\ze,\s*.*')
	let SID = s:get_option(a:context, "SID", chained#to_SID(chained#latest_called_script_function()))

	try
		call s:eval(expr, get(a:context, "local", {}), SID)
		call s:message(extend({ "type" : "F" }, a:context))
	catch
		if s:exception_id(v:exception) !=# matchstr(a:context.expr, '.*,\s*\zs.*\ze')
			call s:message(extend({ "type" : "F" }, a:context))
		else
			call s:message(extend({ "type" : "S" }, a:context))
		endif
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

