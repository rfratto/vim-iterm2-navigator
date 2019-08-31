import iterm2
import socket
import os

async def try_move(connection, direction):
    item = ""
    if direction == 'h':
        item = 'Select Split Pane.Select Pane Left'
    elif direction == 'j':
        item = 'Select Split Pane.Select Pane Below'
    elif direction == 'k':
        item = 'Select Split Pane.Select Pane Above'
    elif direction == 'l':
        item = 'Select Split Pane.Select Pane Right'
    else:
        print('unknown direction ' + l)
        return

    await iterm2.MainMenu.async_select_menu_item(connection, item)

async def main(connection):
    server_address = '/tmp/iterm2.sock'

    # Make sure the socket isn't already running
    try:
        os.unlink(server_address)
    except OSError:
        if os.path.exists(server_address):
            raise

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(server_address)
    sock.listen(1)

    while True:
        conn, _ = sock.accept()
        try:
            data = conn.recv(128)
            data = data.decode("utf-8").strip()

            print('got data')
            try:
                await try_move(connection, data)
            except:
                pass
        finally:
            conn.close()

iterm2.run_forever(main)
