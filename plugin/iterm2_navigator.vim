" Maps <C-h/j/k/l> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to iterm2.
" Additionally, <C-\> toggles between last active vim splits/iterm2 panes.

if exists("g:loaded_iterm2_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_iterm2_navigator = 1

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

if !get(g:, 'iterm2_navigator_no_mappings', 0)
  nnoremap <silent> <c-h> :ITerm2NavigateLeft<cr>
  nnoremap <silent> <c-j> :ITerm2NavigateDown<cr>
  nnoremap <silent> <c-k> :ITerm2NavigateUp<cr>
  nnoremap <silent> <c-l> :ITerm2NavigateRight<cr>
endif

if empty($ITERM_SESSION_ID)
  command! ITerm2NavigateLeft call s:VimNavigate('h')
  command! ITerm2NavigateDown call s:VimNavigate('j')
  command! ITerm2NavigateUp call s:VimNavigate('k')
  command! ITerm2NavigateRight call s:VimNavigate('l')
  command! ITerm2NavigatePrevious call s:VimNavigate('p')
  finish
endif

command! ITerm2NavigateLeft call s:ITerm2AwareNavigate('h')
command! ITerm2NavigateDown call s:ITerm2AwareNavigate('j')
command! ITerm2NavigateUp call s:ITerm2AwareNavigate('k')
command! ITerm2NavigateRight call s:ITerm2AwareNavigate('l')
command! ITerm2NavigatePrevious call s:ITerm2AwareNavigate('p')

if !exists("g:iterm2_navigator_save_on_switch")
  let g:iterm2_navigator_save_on_switch = 0
endif

function! s:ITerm2Command(args)
  let cmd = 'echo ' . a:args . ' | nc -U /tmp/iterm2.sock'
  return system(cmd)
endfunction

let s:iterm2_is_last_pane = 0
augroup iterm2_navigator
  au!
  autocmd WinEnter * let s:iterm2_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardNavigationBackToITerm2(iterm2_last_pane, at_tab_page_edge)
  return a:iterm2_last_pane || a:at_tab_page_edge
endfunction

function! s:ITerm2AwareNavigate(direction)
  let nr = winnr()
  let iterm2_last_pane = (a:direction == 'p' && s:iterm2_is_last_pane)
  if !iterm2_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())
  " Forward the switch panes command to iterm2 if:
  " a) we're toggling between the last iterm2 pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if s:ShouldForwardNavigationBackToITerm2(iterm2_last_pane, at_tab_page_edge)
    if g:iterm2_navigator_save_on_switch == 1
      try
        update " save the active buffer. See :help update
      catch /^Vim\%((\a\+)\)\=:E32/ " catches the no file name error
      endtry
    elseif g:iterm2_navigator_save_on_switch == 2
      try
        wall " save all the buffers. See :help wall
      catch /^Vim\%((\a\+)\)\=:E141/ " catches the no file name error
      endtry
    endif
    silent call s:ITerm2Command(a:direction)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:iterm2_is_last_pane = 1
  else
    let s:iterm2_is_last_pane = 0
  endif
endfunction
