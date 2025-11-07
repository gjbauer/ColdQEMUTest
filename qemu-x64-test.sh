if [ -f dump.bin ]; then
	rm dump.bin
fi

echo "While QEMU is open, after decryption, run the following in the QEMU shell"
echo "pmemsave 0 0x20000000 dump.bin"

qemu-system-x86_64 -m 512M --enable-kvm -cpu host -smp 4 -hda ubuntu_vm_encrypted.qcow2 -net nic,model=virtio -net user -display sdl,gl=on -monitor stdio

dd if=/dev/zero of=dump.img bs=1M count=4096 status=progress
mkfs.fat -F32 dump.img
mkdir mnt
sudo mount -o loop dump.img mnt
cp mnt/dump.bin
qemu-system-x86_64 -m 4G --enable-kvm -cpu host -smp 4 -hda ubuntu_vm.qcow2 -hdb ubuntu_vm_encrypted.qcow2 -drive file=dump.img,format=raw -net nic,model=virtio -net user -display sdl,gl=on
sudo umount mnt
rm -rf mnt
