#!/usr/bin/env python3

import iterm2

async def main(connection):
    @iterm2.RPC
    async def vim_aware_select_pane(direction):
        app = await iterm2.async_get_app(connection)
        window = app.current_terminal_window
        if window == None:
            return
        tab = window.current_tab
        if tab == None:
            return
        session = tab.current_session
        if session == None:
            return

        command = ''
        menu_item = ''

        if direction == 'h':
            command = chr(ord('H') - 64)
            menu_item = 'Select Split Pane.Select Pane Left'
        elif direction == 'j':
            command = chr(ord('J') - 64)
            menu_item = 'Select Split Pane.Select Pane Below'
        elif direction == 'k':
            command = chr(ord('K') - 64)
            menu_item = 'Select Split Pane.Select Pane Above'
        elif direction == 'l':
            command = chr(ord('L') - 64)
            menu_item = 'Select Split Pane.Select Pane Right'

        title = session.pretty_str()
        is_vim = 'vim' in title or 'nvim' in title
        if is_vim:
            await session.async_send_text(command, True)
        else:
            try:
                await iterm2.MainMenu.async_select_menu_item(connection, menu_item)
            except BaseException as err:
                print(f"Unexpected {type(err)=}: {err=}")
                return

    await vim_aware_select_pane.async_register(connection)

iterm2.run_forever(main)
