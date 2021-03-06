" Vim plugin for looking up words in an online thesaurus
" Author:       Anton Beloglazov <http://beloglazov.info/>
" Version:      0.2.4
" Original idea and code: Nick Coleman <http://www.nickcoleman.org/>
" Cross-platform support via Python `thesaurus-lookup.py`: Babil Golam Sarwar
" (gsbabil@gmail.com)

if exists("g:loaded_online_thesaurus")
    finish
endif
let g:loaded_online_thesaurus = 1

let s:save_cpo = &cpo
set cpo&vim
let s:save_shell = &shell
let &shell = '/bin/sh'

let s:path = shellescape(expand("<sfile>:p:h"))

if has("unix")
    silent let s:sort = system('if command -v /bin/sort > /dev/null; then'
         \ . ' printf /bin/sort;'
         \ . ' else printf sort; fi')
endif

function! s:Lookup(word)
    silent! let l:thesaurus_window = bufwinnr('^thesaurus$')

    if l:thesaurus_window > -1
        exec l:thesaurus_window . "wincmd w"
    else
        silent keepalt belowright split thesaurus
    endif

    setlocal noswapfile nobuflisted nospell nowrap modifiable
    setlocal buftype=nofile bufhidden=hide
    let l:word = substitute(a:word, '"', '', 'g')
    let l:word = substitute(a:word, '[!@#$%^&*()_+"]', '', 'g')

    :1,$d

    echo "Requesting thesaurus.com for \"" . l:word . "\"..."
    if has("unix")
        exec ":silent 0r !" . s:path . "/thesaurus-lookup.sh " . shellescape(l:word)
    elseif has("win32")
        let s:win_path = substitute(s:path, "\"$", "", "")
        let s:win_cmd = join([s:win_path, "\\thesaurus-lookup.py\" "], "")
        exec ":silent 0r !python " . s:win_cmd . shellescape(l:word)
    endif
    if has("unix")
        exec ":silent g/\\vrelevant-\\d+/,/^$/!" . s:sort . " -t ' ' -k 1,1r -k 2,2"
    endif
    silent g/\vrelevant-\d+ /s///
    silent! g/^Synonyms/+;/^$/-2s/$\n/, /
    silent g/^Synonyms:/ normal! JVgq

    :0

    exec 'resize ' . (line('$') - 1)
    setlocal nomodifiable filetype=thesaurus
    nnoremap <silent> <buffer> q :q<CR>
endfunction

if !exists('g:online_thesaurus_map_keys')
    let g:online_thesaurus_map_keys = 1
endif

if g:online_thesaurus_map_keys
    nnoremap <unique> <LocalLeader>K :OnlineThesaurusCurrentWord<CR>
endif

command! OnlineThesaurusCurrentWord :call <SID>Lookup(expand('<cword>'))
command! OnlineThesaurusLookup :call <SID>Lookup(expand('<cword>'))
command! -nargs=1 Thesaurus :call <SID>Lookup(<q-args>)

let &cpo = s:save_cpo
let &shell = s:save_shell
