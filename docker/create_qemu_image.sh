#!/usr/bin/env bash
set -eEuo pipefail

# A recent debian image with cloud-init
tag=20210507-630
baseurl="https://cdimage.debian.org/cdimage/cloud/buster/daily/${tag}"
img="debian-10-genericcloud-amd64-daily-${tag}.qcow2"

create() {
    local hostname="example-host"
    local vmimg="debian-example.qcow2"
    local seedimg="seed.img"

    # Download a debian base image with cloud-init
    if [ ! -f "${img}" ]; then
        echo "Downloading ${img}"
        rm -f SHA512SUMS
        wget "${baseurl}/SHA512SUMS"
        wget "${baseurl}/${img}"
        sha512sum -c SHA512SUMS --ignore-missing
    else
        echo "Image ${img} already downloaded"
    fi

    # remove any previous image with the same name
    # qcow2: copy-on-write, base FS provided by unmodified debian base image,
    # the new image $vmimg conly contains the changes
    rm -f "$vmimg"
    qemu-img create -F qcow2 -b "${img}" -f qcow2 "$vmimg" 16G

    # Start emulating the system with two drives:
    # hda: vmimg: at this point the plain debian base image without modifications
    # hdb: seedimg: a simple iso9660 fs that contains user-data, meta-data for cloud-init
    #
    # The base image is configured to run cloud-init on first boot. Cloud-init
    # is configured in the user-data file. In this case, it will install an
    # example service, a package, and shutdown. It also enables password-less
    # root login.
    #
    # For the other qemu parameters, see the documentation
    # https://wiki.qemu.org/Documentation. Here is a short explanation
    #
    # -m 2048 adds 2GB memory to the guest
    # -machine q35 essentially defines the type of mainboard and q35 is needed
    #   for dpdk
    # -device ioh3420 defines a pcie controller to which we will connect a NIC
    # (pcie is also needed for some features used by dpdk)
    # -device virtio-net-pci,...,netdev=net0 defines a NIC that should use the
    #   virtio-net-pci driver (that's the driver used by the guest)
    # -netdev "user,id=net0" 'connects' the NIC with the host OS (using
    # user-mode networking)

    qemu-system-x86_64 \
        -machine q35 \
        -cpu max \
        -smp cpus=4,cores=2,threads=2 \
        -device ioh3420,id=pcie.1,chassis=1 \
        -m 2048 \
        -drive "file=${vmimg},if=virtio" \
        -drive "file=${seedimg},if=virtio" \
        -nographic \
        -device virtio-net-pci,bus=pcie.1,netdev=net0 \
        -netdev "user,id=net0"

    echo "The virtual machine image has been created at ${qemu_dir}/${vmimg}."
}

qemu_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$qemu_dir"
create
