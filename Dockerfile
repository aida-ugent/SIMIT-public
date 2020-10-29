FROM ubuntu:18.04

LABEL maintainer="@bkang" \
      version="1.0" \
      description="MATLAB Runtime R2016b (9.1)"


# Environment
ENV MCR_ROOT="/usr/local/MATLAB/MATLAB_Runtime" \
    MCR_VER="v91" \
    MCR_LINK="https://ssd.mathworks.com/supportfiles/downloads/R2016b/deployment_files/R2016b/installers/glnxa64/MCR_R2016b_glnxa64_installer.zip"

# Setup
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install unzip wget xorg && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*


RUN apt-get -y update && \
    apt-get -y install python2.7 && \
    apt-get -y install python-pip && \
    ln -sf /usr/bin/python2.7 /usr/bin/python && \
    python -V && \
    python -m pip install numpy==1.11.1 && \
    python -m pip install ortools==7.3.7083

# Download and install MCR
RUN wkdir="/tmp/mcr-${MCR_VER}-installer" && \
    mkdir "$wkdir" && \
    wget --no-check-certificate --progress=bar:force -O "$wkdir/mcr-${MCR_VER}.zip" "$MCR_LINK" && \
    unzip -q "$wkdir/mcr-${MCR_VER}.zip" -d "$wkdir/mcr-${MCR_VER}" && \
    rm -f "$wkdir/mcr-${MCR_VER}.zip" && \
    "$wkdir/mcr-${MCR_VER}/install" -mode silent -agreeToLicense yes -destinationFolder "$MCR_ROOT" -tmpdir "$wkdir/tmp" && \
    rm -rf "$wkdir" /tmp/hsperfdata_root



# Environment config
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MCR_ROOT/$MCR_VER/runtime/glnxa64"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MCR_ROOT/$MCR_VER/bin/glnxa64"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MCR_ROOT/$MCR_VER/sys/os/glnxa64"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MCR_ROOT/$MCR_VER/sys/opengl/lib/glnxa64"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MCR_ROOT/$MCR_VER/extern/bin/glnxa64" \
    XAPPLRESDIR="$MCR_ROOT/$MCR_VER/X11/app-defaults" \
    MCR_CACHE_ROOT=/tmp \
    MCR_CACHE_VERBOSE=true