# Container for running Vivado on M1/M2 macs
# though it should work equally on Intel macs
FROM --platform=linux/amd64 ubuntu:22.04
RUN apt-get update && apt-get upgrade -y

# Fix the error of build failing due to not having the frontend installed
# This enviroment auto fallbacks to noninteractive mode, with the declaration following this guidance:
# https://bobcares.com/blog/debian_frontendnoninteractive-docker/
# https://github.com/moby/moby/issues/4032#issuecomment-34597177
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Check and install ca-certificates earlier if Rosetta gets broken
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# install gui
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    dbus dbus-x11 x11-utils xorg alsa-utils mesa-utils net-tools \
    libgl1-mesa-dri gtk2-engines lxappearance fonts-droid-fallback sudo firefox \
    ubuntu-gnome-default-settings curl gnupg lxde arc-theme \
    gtk2-engines-murrine gtk2-engines-pixbuf gnome-themes-standard nano xterm \
    wget; \
    rm -rf /var/lib/apt/lists/*

# install dependencies for Vivado
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    python3-pip python3-dev build-essential git gcc-multilib g++ \
    ocl-icd-opencl-dev libjpeg62-dev libc6-dev-i386 graphviz make \
    unzip libtinfo5 xvfb libncursesw5 locales libswt-gtk-4-jni; \
    rm -rf /var/lib/apt/lists/*

# install vnc server (with recommended installs)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-xorg-extension tigervnc-tools; \
    rm -rf /var/lib/apt/lists/*

# create user "user" with password "password"
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:password" | chpasswd'
# RUN cp -r /root/{.config,.gtkrc-2.0,.asoundrc} /home/user
RUN chown -R user:user /home/user
# setup LXDE
RUN mkdir -p /home/user/.config/pcmanfm/LXDE/
RUN ln -sf /usr/local/share/doro-lxde-wallpapers/desktop-items-0.conf \
    /home/user/.config/pcmanfm/LXDE/
RUN mv /usr/bin/lxpolkit /usr/bin/lxpolkit.bak
#RUN echo "" >> /etc/xdg/lxsession/LXDE/autostart
#RUN echo "@lxterminal -e /home/user/scripts/de_start.sh" >> /etc/xdg/lxsession/LXDE/autostart
# setup TigerVNC
RUN sed -i 's/-iconic/-nowin/g' /etc/X11/Xtigervnc-session
RUN mkdir /home/user/.vnc
RUN mkdir -p /home/user/Xilinx
RUN echo "password" | vncpasswd -f > /vncpasswd
RUN chown user /vncpasswd
RUN chown user /home/user/Xilinx
RUN chmod 600 /vncpasswd

# Set the locale, because Vivado crashes otherwise
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PAYLOAD_LOCATION_FROM_USER=/home/user/Xilinx/payload
# Without this, Vivado will crash when synthesizing
ENV LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0"
