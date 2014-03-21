scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#goimport#define()
  return s:source
endfunction


let s:source = {
      \   'name' : 'goimport',
      \   'hooks' : {},
      \   'sorters' : 'sorter_nothing'
      \ }
      " \   'default_kind' : 'golang_import',



function! s:source.gather_candidates(args, context)
  let pattern = get(a:args, 0, @/)
  let list    = ['hi','there',pattern]
  return map(items(list), '{
        \   'word' : v:val,
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
