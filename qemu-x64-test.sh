if [ -f dump.bin ]; then
	rm dump.bin
fi

echo "While QEMU is open, after decryption, run the following in the QEMU shell"
echo "pmemsave 0 0x20000000 dump.bin"

qemu-system-x86_64 -m 512M --enable-kvm -cpu host -smp 4 -hda ubuntu_vm_encrypted.qcow2 -net nic,model=virtio -net user -display sdl,gl=on -monitor stdio

LOOP_DEVICE=$(sudo losetup -f)
dd if=/dev/zero of=keys.img bs=1M count=4096 status=progress
sudo losetup "$LOOP_DEVICE" keys.img
sudo sgdisk -Z "$LOOP_DEVICE" && sudo sgdisk -n 0:0:0 "$LOOP_DEVICE"
sudo partprobe "$LOOP_DEVICE"
sudo mkfs.fat -F32 "$LOOP_DEVICE"p1
mkdir mnt
sudo mount -o loop "$LOOP_DEVICE"p1 mnt
# Processing on host machine is faster than on VM...
cryptosift -st 1 -nc dump.bin mnt/*
sudo umount mnt
sudo losetup -d "$LOOP_DEVICE"
rm -rf mnt
qemu-system-x86_64 -m 4G --enable-kvm -cpu host -smp 4 -hda ubuntu_vm.qcow2 -hdb ubuntu_vm_encrypted.qcow2 -drive file=keys.img,format=raw -net nic,model=virtio -net user -display sdl,gl=on
