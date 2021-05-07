FROM ubuntu:focal

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    docker.io \
    iproute2 \
    iputils-ping \
    qemu-system \
    qemu-utils \
    sudo \
    vim \
    wget


### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

COPY seed.img /seed.img
COPY create_qemu_image.sh /create_qemu_img.sh
