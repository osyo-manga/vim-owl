

function! s:SID()
	return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun


function! s:plus(a, b)
" 	return a:a - a:b
	return a:a + a:b
endfunction


function! OwlTestGlobalFunction()
	return "test"
endfunction

OwlCheck OwlTestGlobalFunction() == "test"

call owl#check({
\	"expr" : "1 == 1",
\})

call owl#equal({
\	"expr" : "1, 1",
\})



function! s:test_plus()
	OwlCheck s:plus(1, 2) == 3
	OwlCheck 3 == s:plus(1, 2)

	let n = 3
	OwlCheck s:plus(1, 2) == n
	OwlCheck s:plus(s:plus(1, 2), 2) == 5
	OwlCheck s:plus(s:plus(1, 2), 2) == s:plus(2, 3)

" 	OwlCheckNot s:plus(1, 2) == 1
" 	OwlCheckNot s:plus(1, 2) == 1

	OwlEqual s:plus("homu", "mado"), 0

	OwlThrow s:plus({}, "homu"), E731
"	OwlThrow s:plus(1, 2) == 3, E118

	let s:plus_test_value = 3
	OwlThrow s:plus(1, 2) == s:plus_test_value, E121
endfunction


function! s:minus(a, b)
	return a:a - a:b
endfunction

function! s:main()
	call s:test_plus()
" 	echo chained#SID()
endfunction
call s:main()




