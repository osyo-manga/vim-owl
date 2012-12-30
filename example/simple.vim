
function! s:plus(a, b)
	return type(a:a) == type("") && type(a:b) == type("") 
\		 ? a:a . a:b
\		 : a:a + a:b
endfunction


" テストコードを記述するスクリプトローカル関数を定義する
" s:test_{名前} 名で定義
function! s:test_plus_success()
	" 引数の式が真であれば成功
	" スクリプトローカル関数を渡すことが出来る
	OwlCheck s:plus(1, 2) == 3

	" ローカル変数を参照することも可能
	let homumami = "homumami"
	OwlCheck s:plus("homu", "mami") == homumami
	
	" OwlEqual s:plus(1, 2) ==  s:plus(5, -2) とほぼ等価
	OwlEqual s:plus(1, 2), s:plus(5, -2)
	
	" 例外排出時のチェック
	OwlThrow s:plus([], {}), E745
endfunction

function! s:test_plus_failure()
	OwlCheck s:plus(1, 2) == 1

	let mamihomu = "mamihomu"
	OwlCheck s:plus("homu", "mami") == mamihomu
	
	" OwlCheck とは違い
	" s:plus(1, 2) と s:plus(5, -5) が評価された値が出力される
	OwlEqual s:plus(1, 2), s:plus(5, -5)
	
	OwlThrow s:plus([], {}), E740
endfunction


" テストコードが書かれたファイル名を渡す
" 自動的に s:test_{名前} の関数を評価する
call owl#run(expand("<sfile>"))

" 直接関数を呼び出しても可
" call s:test_plus_success()
" call s:test_plus_failure()

" quickrun.vim で実行する場合
" QuickRun -outputter quickfix

