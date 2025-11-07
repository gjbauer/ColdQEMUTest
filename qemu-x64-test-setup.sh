qemu-img create -f qcow2 ubuntu_vm_encrypted.qcow2 30G

qemu-system-x86_64 -m 4G --enable-kvm -cpu host -smp 4 -hda ubuntu_vm_encrypted.qcow2 -cdrom ~/Downloads/ubuntu*.iso -boot order=d -net nic,model=virtio -net user -display sdl,gl=on

qemu-img create -f qcow2 ubuntu_vm.qcow2 30G

qemu-system-x86_64 -m 4G --enable-kvm -cpu host -smp 4 -hda ubuntu_vm.qcow2 -cdrom ~/Downloads/ubuntu*.iso -boot order=d -net nic,model=virtio -net user -display sdl,gl=on
