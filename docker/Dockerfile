FROM ubuntu:focal

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    docker.io \
    qemu-system

RUN apt-get install -y iproute2 qemu-utils ssh vim wget


COPY seed.img /seed.img
COPY create_qemu_image.sh /create_qemu_img.sh
