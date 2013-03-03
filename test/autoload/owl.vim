

source <sfile>:p:h/owl_test.vim

let s:filename = expand("<sfile>")

" let g:owl_success_message_format = ""
" let g:owl_success_message_format = "%f:%l:[Success] %e"
" let g:owl_failure_message_format = "%f:%l:[Failure] %e"


function! s:plus(a, b)
	return a:a + a:b
endfunction


function! s:test_to_SNR()
	let owl_SID = owl#filename_to_SID("vim-owl/autoload/owl.vim")
	OwlCheck s:to_SNR(22) == "<SNR>22_"
endfunction


function! s:test_check()
	call owl#check({
\		"expr" : "1 == 1",
\	})
	OwlCheck 1 == 1

	call owl#check({
\		"expr" : "s:plus(1, 2) == 3",
\	})
	OwlCheck s:plus(1, 2) == 3
endfunction


function! s:test_check_owl_SID()
	let test_SID = owl#filename_to_SID("vim-owl/test/autoload/owl_test.vim")
	let g:owl_SID = test_SID

	call owl#check({
\		"expr" : "s:minus(1, 2) == -1",
\	})
	OwlCheck s:minus(1, 2) == -1

	let g:owl_SID = 22222

	let owl_SID = test_SID

	call owl#check({
\		"expr" : "s:minus(1, 2) == -1",
\		"local" : l:
\	})
	OwlCheck s:minus(1, 2) == -1

	let owl_SID = 22222

	call owl#check({
\		"expr" : "s:minus(1, 2) == -1",
\		"SID" : test_SID
\	})

	unlet owl_SID
	unlet g:owl_SID
endfunction


function! s:test_check_local_value()
	let n = 10
	call owl#check({
\		"expr" : "s:plus(6, 4) == n",
\		"local" : l:
\	})
	OwlCheck s:plus(-5, 15) == n
endfunction


function! s:test_equal()
" 	call owl#equal({
" \		"left"  : "1",
" \		"right" : "1",
" \	})

	call owl#equal({
\		"expr" : "s:plus(1, 2), 3",
\	})

	OwlEqual 1, 1
	OwlEqual s:plus(1, 2) == 3
	OwlEqual "homu" == "homu"

	let homu = "homu"
	OwlEqual homu == "homu"
endfunction


function! s:test_equal_owl_SID()
	let test_SID = owl#filename_to_SID("vim-owl/test/autoload/owl_test.vim")
	let g:owl_SID = test_SID

	call owl#equal({
\		"expr" : "s:minus(1, 2), -1",
\	})
	OwlEqual s:minus(1, 2), -1

	let g:owl_SID = 22222

	let owl_SID = test_SID

	call owl#equal({
\		"expr" : "s:minus(1, 2), -1",
\		"local" : l:
\	})
	OwlEqual s:minus(1, 2), -1

	let owl_SID = 22222

	call owl#equal({
\		"expr" : "s:minus(1, 2), -1",
\		"SID" : test_SID
\	})

	unlet owl_SID
	unlet g:owl_SID
endfunction


function! s:test_equal_local_value()
	let n = 3

	OwlEqual n, 3
	OwlEqual s:plus(1, 2), n
endfunction


function! s:test_throw()
	call owl#throw({
\		"expr" : "s:plus({}, 'homu'), E731"
\	})
	OwlThrow s:plus({}, "homu"), E731
	OwlThrow s:minus(1, 2) == 3, E117
endfunction


function! s:test_get_option()
	let owl_SID = owl#filename_to_SID("vim-owl/autoload/owl.vim")

	OwlEqual s:get_option({}, "hoge"), ""
	OwlEqual s:get_option({}, "hoge", 10), 10
	OwlEqual s:get_option({ "local" : {} }, "hoge", 10), 10
	OwlEqual s:get_option({ "local" : { "owl_hoge" : 24 } }, "hoge", 10), 24

	let owl_hoge = 34
	OwlEqual s:get_option({ "local" : l: }, "hoge", 10), 34

	let g:owl_hoge = 36
	OwlEqual s:get_option({ "local" : l: }, "hoge", 10), 34

	unlet owl_hoge
	OwlEqual s:get_option({ "local" : {} }, "hoge", 10), 36
	unlet g:owl_hoge
	OwlEqual s:get_option({ "local" : {} }, "hoge", 10), 10

	OwlEqual s:get_option({ "hoge" : 42 }, "hoge", 10), 42
endfunction


function! s:test_eval()
	let owl_SID = owl#filename_to_SID("vim-owl/autoload/owl.vim")

	OwlCheck s:eval("1 == 1", {}, 0) == 1

	let n = 10
	OwlCheck s:eval("n == 10", l:, 0) == 1
endfunction


function! s:test_print_message()
	let owl_SID = owl#filename_to_SID("vim-owl/autoload/owl.vim")

	OwlEqual s:print_message("%f:%l:%m%%", "file.vim", 10, "1", "homu"), "file.vim:10:homu%"
	OwlEqual s:print_message("%%", "file.vim", 10, "1", "homu"), "%"
	OwlEqual s:print_message("%%f", "file.vim", 10, "1", "homu"), "%f"
	OwlEqual s:print_message("%l%l%l", "file.vim", 10, "1", "homu"), "101010"
endfunction



function! s:owl_begin()
" 	let g:owl_success_message_format = "%f:%l:[Success] %e"
endfunction

function! s:owl_end()
" 	let g:owl_success_message_format = ""
endfunction

" call G_owl_run(expand("<sfile>"))
" call owl#run(expand("<sfile>"))

