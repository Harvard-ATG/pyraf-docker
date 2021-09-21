FROM ubuntu:18.04
RUN apt-get update -y \
    && apt-get install -y tcsh iputils-ping x11-apps xauth python3-pyraf 

