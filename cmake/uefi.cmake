find_file(ovmf_firmware OVMF.fd HINTS /usr/share/ovmf /usr/share/edk2/x64 /usr/share/qemu DOC "OVMF UEFI firmware for QEMU")
find_program(qemu     NAMES qemu-system-x86_64 DOC "QEMU for x86_64 emulation")

set(QEMU_MEMORY 512M)
set(QEMU_UEFI       -net none -drive if=pflash,format=raw,readonly=on,file=${ovmf_firmware} -m ${QEMU_MEMORY} -machine q35)
set(QEMU_FLAGS      -drive format=qcow2,file=firmware.qcow2,if=pflash,readonly=on -m ${QEMU_MEMORY} -machine q35 -d int,guest_errors --serial file:log.txt -device qemu-xhci --device isa-debugcon,iobase=0x402,chardev=debug -chardev file,id=debug,path=debug.log)

add_custom_command(
    OUTPUT firmware.qcow2
    COMMAND ${qemu_img} create -o backing_file=${ovmf_firmware} -o backing_fmt=raw -o cluster_size=512 -f qcow2 firmware.qcow2
    DEPENDS ${ovmf_firmware}
)

add_custom_target(debug
    COMMAND ${qemu} ${QEMU_FLAGS} ${QEMU_FLAGS_NVME} --daemonize -s -S
    COMMAND ${gdb} -ix gdbinit
    DEPENDS hd.img gdbinit firmware.qcow2
    USES_TERMINAL
)

add_custom_target(uefi
    COMMAND ${qemu} ${QEMU_UEFI}
    USES_TERMINAL
)

add_custom_target(run
    COMMAND ${qemu} ${QEMU_FLAGS} ${QEMU_FLAGS_NVME}
    USES_TERMINAL
)

set(GDB_COMMANDS ${build_userspace})
list(TRANSFORM GDB_COMMANDS PREPEND "add-symbol-file shared/userspace/")
list(JOIN GDB_COMMANDS "\n" GDB_COMMANDS)
#configure_file(gdbinit.in gdbinit)
