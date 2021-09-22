# pyraf-docker

Docker image for running [pyraf](https://iraf-community.github.io/).

## Docker

To build and push a new image:

```
$ docker build -t harvardat/pyraf .
$ docker run --rm -it harvardat/pyraf:latest /bin/bash -c "pyraf --version"
$ docker login
$ docker push harvardat/pyraf
```

To run `pyraf` and use X apps, follow the instructions below.

## X Window System

### Background 

The Linux graphical windowing system is called X11, also known as X Windows, or X for short. _X forwarding_ is a feature of X where a graphical program runs on one computer, but the user interacts with it on another computer. If you've ever used Remote Desktop, it's conceptually like that, but it works on a program-by-program or window-by-window basis. 

### Installation

For Mac OS X, install [XQuartz](https://www.xquartz.org/).

### Configuration

1. Ensure that you have an `~/.Xauthority` file (a binary file used to authorize connections to the `DISPLAY`):
    ```
    $ touch ~/.Xauthority
    ```
2. Add `XAuthLocation` to `~/.ssh/config`:
    ```
    XAuthLocation /opt/X11/bin/xauth
    ```
    This is so that `ssh` knows where to find the `xauth` program that is provided by XQuartz, since it's in a non-standard location.
3. Add `ForwardX11Timeout` to `~/.ssh/config`:
    ```
    ForwardX11Timeout 10h
    ```
    This increases the default timeout from 20min to 10hrs. Note that this only applies if `ForwardX11Trusted no` (e.g. `ssh -X` instead of `ssh -Y`).

### DISPLAY and Xauthority

The most important environment variable for X is `$DISPLAY`. This will be set by your X server (e.g. XQuartz) and defines a value in the following format: `hostname:D.S`.

-  `hostname` is the name of the computer the X server runs on (`localhost` if omitted).
-  `D` is a sequence number if there are multiple displays.
-  `S` is a screen number (typically 0 because there's one secreen)

The `.Xauthority` file is used to authorize cookie-based access to the `$DISPLAY`. It defines a "magic cookie" that must be presented by X clients when connecting to the X display server.

Since this is a binary file, you can't view it directly, but must use the `xauth` command:

```
$ echo $DISPLAY
$ xauth list
```

See also:
- https://en.wikipedia.org/wiki/X_Window_authorization
- https://datacadamia.com/ssh/x11/display

## Running the docker image on Mac OS X

Assumes you have [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/) and you want to run the docker image locally.

1. Install [socat](https://linux.die.net/man/1/socat):
    ```
    $ brew install socat
    ```
2. Launch XQuartz
    ```
    $ open -a XQuartz
    ```
3. Go to the XQuartz security tab and ensure _Allow connections from network clients_ is checked.
4. Use `socat` to forward traffic from port 6000 to the unix display socket:
    ```
    $ socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
    $ lsof -i TCP:6000 # verify socat is listening
    ```
5. Start docker:
    ```
    $ docker pull harvardat/pyraf:latest
    $ docker run --rm -e DISPLAY=docker.for.mac.host.internal:0 -it harvardat/pyraf:latest /bin/tcsh
    ```
6. Run an X11 app such as `xterm` or `xeyes`
    ```
    $ xterm &
    ```
    If successful, you should see an `xterm` open on your desktop. 
7. Run `pyraf`:
    ```
    $ pyraf
    ```

## Running the docker image on a remote EC2

Assumes you have an Ubuntu EC2 instance with [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) installed and you want to run the docker image remotely, but interact with it locally on your desktop. 

1. Launch XQuartz
    ```
    $ open -a XQuartz
    ```
2. Connect to the EC2 with X Forwarding enabled:
    ```
    $ ssh -X ubuntu@<IP>
    $ touch ~/.Xauthority
    ```
3. Start docker:
    ```
    $ docker pull harvardat/pyraf:latest
    $ docker run --rm -e DISPLAY --network host -v "$HOME/.Xauthority:/root/.Xauthority:rw" -it harvardat/pyraf:latest /bin/tcsh
    ```
4. Run an X11 app such as `xterm` or `xeyes`
    ```
    $ xterm &
    ```
    If successful, you should see an `xterm` open on your desktop. 
5. Run `pyraf`:
    ```
    $ pyraf
    ```

_Note:_ The X client within the docker container must be able to find the X server specified in the `$DISPLAY`. By setting the docker network to `host` instead of `bridge`, it will be able to easily resolve the hostname and connect to the X server (which in this case is SSHD proxying the request back to your computer). Note that this technique is not recommended for deployment, just for testing.
