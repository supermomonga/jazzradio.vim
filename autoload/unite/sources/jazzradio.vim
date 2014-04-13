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
      \   'default_action' : 'play',
      \   '__counter' : 0
      \ }

function! s:source.action_table.play.func(candidate)
  call jazzradio#play(a:candidate.action__channel_id)
endfunction

function! s:source.async_gather_candidates(args, context)
  let channels = jazzradio#channel_list()
  let max_name_len = max(map(copy(channels), 'len(v:val["name"])'))
  let label = jazzradio#current_channel() == '' ? '' : g:jazzradio#playing_label_frames[self.__counter]
  let label_len = len(label) > 0 ? len(label) + 1 : 0
  let format = '%-' . label_len . 's%-' . max_name_len . 's - %s'
  if self.__counter == len(g:jazzradio#playing_label_frames) - 1
    let self.__counter = 0
  else
    let self.__counter += 1
  endif
  let a:context.source.unite__cached_candidates = []
  return map(channels, '{
        \   "word" : printf(format, jazzradio#current_channel() == v:val["key"] ? label : "" , v:val["name"], v:val["description"]),
        \   "action__channel_id" : v:val["key"],
        \ }')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
