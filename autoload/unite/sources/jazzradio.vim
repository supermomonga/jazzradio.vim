scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#jazzradio#define()
  return s:source
endfunction


let s:source = {
      \   'name' : 'jazzradio',
      \   'hooks' : {},
      \   'action_table' : {
      \     'play' : {
      \       'description' : 'Play this radio',
      \     }
      \   },
      \   'default_action' : 'play'
      \ }

function! s:source.action_table.play.func(candidate)
  call jazzradio#play(a:candidate.action__channel_id)
endfunction

function! s:source.gather_candidates(args, context)
  let channels = jazzradio#channel_list()
  return map(channels, '{
        \   "word" : v:val["name"] . " - " . v:val["description"],
        \   "action__channel_id" : v:val["key"],
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
