FROM ubuntu:18.04

# Install system packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
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
    python3-pyraf

# Install Miniconda
RUN curl -sSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local \ 
    && rm -f /tmp/miniconda.sh \
    && conda update conda \
    && conda clean --all --yes

# Setup Astroconda Repo + Environment
RUN conda config --add channels http://ssb.stsci.edu/astroconda \
    && conda create -y -n astroconda python=3.7 stsci 

