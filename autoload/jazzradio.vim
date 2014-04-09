

" Load vital modules
let s:V = vital#of('jazzradio')
let s:CACHE = s:V.import('System.Cache')
let s:JSON = s:V.import('Web.JSON')
let s:HTML = s:V.import('Web.HTML')
let s:HTTP = s:V.import('Web.HTTP')
let s:PM = s:V.import('ProcessManager')


" Player
function! jazzradio#play(id) " {{{
  if executable('mplayer')
    if s:PM.is_available()
      let endpoint = jazzradio#read_cache()[a:id]['endpoints'][0]
      let play_command = substitute(g:jazzradio#play_command, '%%URL%%', endpoint, '')
      call jazzradio#stop()
      call s:PM.touch('jazzradio_radio', play_command)
      echo play_command
    else
      echo 'Error: vimproc is unavailable.'
    endif
  else
    echo 'Error: Please install mplayer to listen streaming radio.'
  endif
endfunction " }}}
function! jazzradio#stop() " {{{
  let status = 'dead'
  try
    let status = s:PM.status('jazzradio_radio')
  catch
  endtry
  if status == 'inactive' || status == 'active'
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
  " TODO: It takes too long time. Make it async and unite UI.
  let channels = {}
  let dom = s:HTML.parseURL('http://www.jazzradio.com/')
  let list_doms = filter(dom.find('ul', {'id': 'channels'}).findAll('li'), "has_key(v:val['attr'], 'data-key')")
  for list in list_doms
    let channel_id = list['attr']['data-key']
    let channel_name = list.find('strong').value()
    let channel_desc = substitute(list.find('span').value(), '^' . channel_name, '', '')
    let endpoints = s:JSON.decode(s:HTTP.get('http://listen.jazzradio.com/webplayer/avantgarde.json').content)
    let channels[channel_id] = {
          \   'id': channel_id,
          \   'name': channel_name,
          \   'desc': channel_desc,
          \   'endpoints': endpoints
          \ }
  endfor
  return jazzradio#write_cache(channels)
endfunction " }}}
function! jazzradio#channel_list() " {{{
  return jazzradio#read_cache()
endfunction " }}}
function! jazzradio#channel_id_list() " {{{
  let channels = jazzradio#read_cache()
  let list = keys(channels)
  return list
endfunction " }}}
function! jazzradio#channel_id_complete(a,l,p) " {{{
  " TODO: filter
  return jazzradio#channel_id_list()
endfunction " }}}


" Cache handling
function! jazzradio#clear_cache() " {{{
  return s:CACHE.deletefile(g:jazzradio#cache_dir, 'channel_list.vson')
endfunction " }}}
function! jazzradio#has_cache() " {{{
  return jazzradio#read_cache() != {}
endfunction " }}}
function! jazzradio#read_cache() " {{{
  let lines = s:CACHE.readfile(g:jazzradio#cache_dir, 'channel_list.vson')
  let data = s:JSON.decode(len(lines) == 0 ? '{}' : lines[0])
  return data
endfunction
" }}}
function! jazzradio#write_cache(data) " {{{
  let lines = [s:JSON.encode(a:data)]
  return s:CACHE.writefile(g:jazzradio#cache_dir, 'channel_list.vson', lines)
endfunction
" }}}
function! jazzradio#write_dummy_cache() " {{{
  let data = {
        \   'avantgarde': {
        \     'id': 'avantgarde',
        \     'name': 'Avang-Garde',
        \     'desc': 'Hi.',
        \     'endpoints': [
        \       'http://pub6.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub1.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub8.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub4.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub2.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub5.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub3.jazzradio.com:80/jr_avantgarde_aacplus.flv',
        \       'http://pub7.jazzradio.com:80/jr_avantgarde_aacplus.flv'
        \     ]
        \   }
        \ }
  let lines = [s:JSON.encode(data)]
  return s:CACHE.writefile(g:jazzradio#cache_dir, 'channel_list.vson', lines)
endfunction
" }}}

" Variables
let g:jazzradio#cache_dir = get(g:, 'jazzradio#cache_dir', expand("~/.cache/jazzradio"))
let g:jazzradio#play_command = get(g:, 'jazzradio#play_command', "mplayer -slave -quiet %%URL%%")

