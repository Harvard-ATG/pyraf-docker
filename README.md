# edoberger-docker

Build and Run image:

```
$ docker build -t pyraf .
$ ssh -Y ubuntu@<IP>
$ docker run --expose 6000-6063 -e DISPLAY -it pyraf:latest /bin/bash
```
