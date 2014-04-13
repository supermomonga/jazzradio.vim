

" Load vital modules
let s:V = vital#of('jazzradio')
let s:CACHE = s:V.import('System.Cache')
let s:JSON = s:V.import('Web.JSON')
let s:HTML = s:V.import('Web.HTML')
let s:HTTP = s:V.import('Web.HTTP')
let s:PM = s:V.import('ProcessManager')


" Player
function! jazzradio#play(key) " {{{
  if executable('mplayer')
    if s:PM.is_available()
      let channel = jazzradio#channel(a:key)
      let playlist = channel['playlist']
      let play_command = substitute(g:jazzradio#play_command, '%%URL%%', playlist, '')
      call jazzradio#stop()
      call s:PM.touch('jazzradio_radio', play_command)
      echo 'Playing ' . channel['name'] . '.'
      let g:jazzradio#current_channel = channel['key']
    else
      echo 'Error: vimproc is unavailable.'
    endif
  else
    echo 'Error: Please install mplayer to listen streaming radio.'
  endif
endfunction " }}}
function! jazzradio#channel(key) " {{{
  let channels = jazzradio#channel_list()
  return get(filter(channels, 'v:val["key"] == "' . a:key . '"'), 0)
endfunction " }}}
function! jazzradio#is_playing(...) " {{{
  " Process status
  let status = 'dead'
  try
    let status = s:PM.status('jazzradio_radio')
  catch
  endtry

  if status == 'inactive' || status == 'active'
    return 1
  else
    return 0
  endif
endfunction " }}}
function! jazzradio#current_channel() " {{{
  if jazzradio#is_playing()
    return get(g:, 'jazzradio#current_channel', '')
  else
    return ''
  endif
endfunction " }}}
function! jazzradio#stop() " {{{
  if jazzradio#is_playing()
    return s:PM.kill('jazzradio_radio')
  endif
endfunction " }}}
function! jazzradio#pause() " {{{
  " TODO
endfunction " }}}
function! jazzradio#resume() " {{{
  " TODO
endfunction " }}}
function! jazzradio#volume_up(level) " {{{
  " TODO
endfunction " }}}
function! jazzradio#volume_down(level) " {{{
  " TODO
endfunction " }}}
function! jazzradio#set_volume(level) " {{{
  " TODO
endfunction " }}}


" Channel handling
function! jazzradio#update_channels() " {{{
  let channels = s:JSON.decode(s:HTTP.get('http://listen.jazzradio.com/webplayer.json').content)
  " echo type(s:JSON.decode(channels))
  if jazzradio#has_cache(g:jazzradio#cache_previous_version)
    call jazzradio#clear_cache(g:jazzradio#cache_previous_version)
  endif
  return jazzradio#write_cache(channels)
endfunction " }}}
function! jazzradio#channel_list() " {{{
  call jazzradio#update_cache_compatibility()
  return jazzradio#read_cache()
endfunction " }}}
function! jazzradio#channel_key_list() " {{{
  return map(jazzradio#channel_list(), 'v:val["key"]')
endfunction " }}}
function! jazzradio#channel_key_complete(a,l,p) " {{{
  " TODO: filter
  return jazzradio#channel_key_list()
endfunction " }}}

" Cache handling
function! jazzradio#cache_filename(...) " {{{
  let cache_version = get(a:, 1, g:jazzradio#cache_version)
  return 'channel_list_v' . cache_version . '.json'
endfunction " }}}
function! jazzradio#clear_cache(...) " {{{
  " TODO: depends on versions var is yokunai.
  let cache_version = get(a:, 1, g:jazzradio#cache_version)
  return s:CACHE.deletefile(g:jazzradio#cache_dir, jazzradio#cache_filename(cache_version))
endfunction " }}}
function! jazzradio#has_cache(...) " {{{
  let cache_version = get(a:, 1, g:jazzradio#cache_version)
  return jazzradio#read_cache(cache_version) != []
endfunction " }}}
function! jazzradio#read_cache(...) " {{{
  let cache_version = get(a:, 1, g:jazzradio#cache_version)
  let lines = s:CACHE.readfile(g:jazzradio#cache_dir, jazzradio#cache_filename(cache_version))
  let data = s:JSON.decode(len(lines) == 0 ? '[]' : lines[0])
  return data
endfunction " }}}
function! jazzradio#write_cache(data, ...) " {{{
  let cache_version = get(a:, 1, g:jazzradio#cache_version)
  let lines = [s:JSON.encode(a:data)]
  return s:CACHE.writefile(g:jazzradio#cache_dir, jazzradio#cache_filename(cache_version), lines)
endfunction
" }}}
function! jazzradio#update_cache_compatibility() " {{{
  if !jazzradio#has_cache()
    call jazzradio#update_channels()
  end
endfunction " }}}

" Variables
let g:jazzradio#cache_version = '1.0'
let g:jazzradio#cache_previous_version = ''
let g:jazzradio#cache_dir = get(g:, 'jazzradio#cache_dir', expand("~/.cache/jazzradio"))
let g:jazzradio#play_command = get(g:, 'jazzradio#play_command', "mplayer -slave -really-quiet -playlist %%URL%%")
let g:jazzradio#playing_label_frames = get(g:, 'jazzradio#playing_label_frames', [
      \   '    ',
      \   '||  ',
      \   '||||',
      \   '||| ',
      \   '|   ',
      \   '||| ',
      \   '||||',
      \   '||| ',
      \   '||||',
      \   '|   ',
      \   '    ',
      \   '    ',
      \   '||  ',
      \   '|   ',
      \   '||  ',
      \   '||||',
      \   '||||',
      \   '||| ',
      \   '||||',
      \   '|   ',
      \ ])

