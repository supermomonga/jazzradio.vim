scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#goimport#define()
  return s:source
endfunction


let s:source = {
      \   'name' : 'goimport',
      \   'hooks' : {},
      \   'action_table' : {
      \     'import' : {
      \       'description' : 'Import package',
      \     }
      \   },
      \   'default_action' : 'import'
      \ }

function! s:source.action_table.import.func(candidate)
  let package = a:candidate.action__package_name
  let last_char = package[-1:]
  if last_char == '/'
    execute 'Unite goimport -input=' . package
  else
    execute 'GoImport ' . package
  endif
endfunction

function! s:source.async_gather_candidates(args, context)
  let a:context.source.unite__cached_candidates = []
  let list    = go#complete#Package(a:context.input,0,0)
  return map(list, '{
        \   "word" : v:val,
        \   "action__package_name" : v:val,
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
