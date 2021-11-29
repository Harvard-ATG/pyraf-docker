FROM ubuntu:18.04

# Install system packages
# NOTE: the 'unminimize' command installs the standard Ubuntu Server packages (including manpages).
# See also: https://wiki.ubuntu.com/Minimal
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && yes | unminimize \
    && apt-get install -y \
    iputils-ping \
    unzip \
    curl \
    wget \
    tcsh \
    vim \
    emacs \
    x11-apps \
    xauth \
    python3-pyraf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Remove the "saods9" package automatically installed by "python3-pyraf"
# because a newer version of the "ds9" tool (https://ds9.si.edu/)
# will be installed by the conda package manager into the 
# astroconda environment.
# 
# This will help avoid any conflicts between the two versions.
# 
# See also:
#   https://packages.ubuntu.com/bionic/python3-pyraf
#     https://packages.ubuntu.com/bionic/iraf
#       https://packages.ubuntu.com/bionic/saods9
RUN apt-get remove -y --purge saods9

# Install Miniconda
RUN curl -sSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local \ 
    && rm -f /tmp/miniconda.sh \
    && conda update conda \
    && conda clean --all --yes

# Setup Astroconda Environment
RUN conda config --add channels http://ssb.stsci.edu/astroconda \
    && conda create -y -n astroconda python=3.7 stsci 
