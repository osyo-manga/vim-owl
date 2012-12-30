

function! s:test_to_SNR()
	let owl_SID = owl#filename_to_SID("vim-owl/plugin/owl.vim")
	OwlCheck s:to_SNR(22) == "<SNR>22_"
endfunction


function! s:test_exception_id()
	let owl_SID = owl#filename_to_SID("vim-owl/plugin/owl.vim")
	OwlCheck s:to_SNR(22) == "<SNR>22_"
endfunction
call s:test_exception_id()


function! s:test_OwlLetOption()
	let g:test_owl_hogehoge = 20

	OwlLetOption hoge test_owl_hogehoge
	OwlCheck hoge == 20

	let test_owl_hogehoge = 10
	OwlLetOption hoge test_owl_hogehoge
	OwlCheck hoge == 10

	let test_owl_homu = 30
	OwlLetOption homu test_owl_homu
	OwlCheck homu == 30

	OwlLetOption mami mamimami 40
	OwlCheck mami == 40

	unlet test_owl_hogehoge
	OwlLetOption hoge2 test_owl_hogehoge
	OwlCheck hoge2 == 20

	unlet g:test_owl_hogehoge
endfunction


