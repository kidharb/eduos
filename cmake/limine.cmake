find_program(qemu     NAMES qemu-system-x86_64 DOC "QEMU for x86_64 emulation")
set(QEMU_MEMORY 512M)
set(QEMU_UEFI       -net none -drive if=pflash,format=raw,readonly=on,file=${ovmf_firmware} -m ${QEMU_MEMORY} -machine q35)
set(QEMU_FLAGS      -drive format=qcow2,file=firmware.qcow2,if=pflash,readonly=on -m ${QEMU_MEMORY} -machine q35 -d int,guest_errors --serial file:log.txt -device qemu-xhci --device isa-debugcon,iobase=0x402,chardev=debug -chardev file,id=debug,path=debug.log)

add_custom_target(${IMAGE_NAME}
	COMMAND rm -f ${IMAGE_NAME}.hdd
	COMMAND dd if=/dev/zero bs=1M count=0 seek=64 of=${IMAGE_NAME}.hdd
	COMMAND sgdisk ${IMAGE_NAME}.hdd -n 1:2048 -t 1:ef00
    COMMAND make -C _deps/limine-src/
	COMMAND ./_deps/limine-src/limine bios-install ${IMAGE_NAME}.hdd
	COMMAND mformat -i ${IMAGE_NAME}.hdd@@1M
	COMMAND mmd -i ${IMAGE_NAME}.hdd@@1M ::/EFI ::/EFI/BOOT ::/boot ::/boot/limine
	COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M src/kernel/kernel.elf ::/boot
	COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M ../limine.cfg _deps/limine-src/limine-bios.sys ::/boot/limine
	COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M _deps/limine-src/BOOTX64.EFI ::/EFI/BOOT
	COMMAND mcopy -i ${IMAGE_NAME}.hdd@@1M _deps/limine-src/BOOTIA32.EFI ::/EFI/BOOT
    DEPENDS kernel
    USES_TERMINAL
)

add_custom_target(run
	COMMAND ${qemu} -M q35 -m 2G -hda ${IMAGE_NAME}.hdd
    DEPENDS ${IMAGE_NAME}
    USES_TERMINAL
)

#add_custom_command(
#    OUTPUT firmware.qcow2
#    COMMAND ${qemu_img} create -o backing_file=${ovmf_firmware} -o backing_fmt=raw -o cluster_size=512 -f qcow2 firmware.qcow2
#    DEPENDS ${ovmf_firmware}
#)
#
#add_custom_target(ovmf
#    COMMAND mkdir -p ovmf
#	COMMAND cd ovmf && curl -Lo OVMF.fd https://retrage.github.io/edk2-nightly/bin/RELEASEX64_OVMF.fd
#    USES_TERMINAL
#)
#
#add_custom_target(limine
#	COMMAND git clone https://github.com/limine-bootloader/limine.git --branch=v7.x-binary --depth=1
#	COMMAND make -C limine \
#		CC="$(HOST_CC)" \
#		CFLAGS="$(HOST_CFLAGS)" \
#		CPPFLAGS="$(HOST_CPPFLAGS)" \
#		LDFLAGS="$(HOST_LDFLAGS)" \
#		LIBS="$(HOST_LIBS)"
#    USES_TERMINAL
#)


#.PHONY: all
#all: $(IMAGE_NAME).iso
#
#.PHONY: all-hdd
#all-hdd: $(IMAGE_NAME).hdd
#
#.PHONY: run
#run: $(IMAGE_NAME).iso
#	qemu-system-x86_64 -M q35 -m 2G -cdrom $(IMAGE_NAME).iso -boot d
#
#.PHONY: run-uefi
#run-uefi: ovmf $(IMAGE_NAME).iso
#	qemu-system-x86_64 -M q35 -m 2G -bios ovmf/OVMF.fd -cdrom $(IMAGE_NAME).iso -boot d
#
#.PHONY: run-hdd
#run-hdd: $(IMAGE_NAME).hdd
#	qemu-system-x86_64 -M q35 -m 2G -hda $(IMAGE_NAME).hdd
#
#.PHONY: run-hdd-uefi
#run-hdd-uefi: ovmf $(IMAGE_NAME).hdd
#	qemu-system-x86_64 -M q35 -m 2G -bios ovmf/OVMF.fd -hda $(IMAGE_NAME).hdd
#
#
#.PHONY: kernel
#kernel:
#	$(MAKE) -C src
#
#$(IMAGE_NAME).iso: limine kernel
#	rm -rf iso_root
#	mkdir -p iso_root/boot
#	cp -v src/bin/kernel iso_root/boot/
#	mkdir -p iso_root/boot/limine
#	cp -v limine.cfg limine/limine-bios.sys limine/limine-bios-cd.bin limine/limine-uefi-cd.bin iso_root/boot/limine/
#	mkdir -p iso_root/EFI/BOOT
#	cp -v limine/BOOTX64.EFI iso_root/EFI/BOOT/
#	cp -v limine/BOOTIA32.EFI iso_root/EFI/BOOT/
#	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
#		-no-emul-boot -boot-load-size 4 -boot-info-table \
#		--efi-boot boot/limine/limine-uefi-cd.bin \
#		-efi-boot-part --efi-boot-image --protective-msdos-label \
#		iso_root -o $(IMAGE_NAME).iso
#	./limine/limine bios-install $(IMAGE_NAME).iso
#	rm -rf iso_root
#
#$(IMAGE_NAME).hdd: limine kernel
#	rm -f $(IMAGE_NAME).hdd
#	dd if=/dev/zero bs=1M count=0 seek=64 of=$(IMAGE_NAME).hdd
#	sgdisk $(IMAGE_NAME).hdd -n 1:2048 -t 1:ef00
#	./limine/limine bios-install $(IMAGE_NAME).hdd
#	mformat -i $(IMAGE_NAME).hdd@@1M
#	mmd -i $(IMAGE_NAME).hdd@@1M ::/EFI ::/EFI/BOOT ::/boot ::/boot/limine
#	mcopy -i $(IMAGE_NAME).hdd@@1M src/bin/kernel ::/boot
#	mcopy -i $(IMAGE_NAME).hdd@@1M limine.cfg limine/limine-bios.sys ::/boot/limine
#	mcopy -i $(IMAGE_NAME).hdd@@1M limine/BOOTX64.EFI ::/EFI/BOOT
#	mcopy -i $(IMAGE_NAME).hdd@@1M limine/BOOTIA32.EFI ::/EFI/BOOT
#
#.PHONY: clean
#clean:
#	rm -rf iso_root $(IMAGE_NAME).iso $(IMAGE_NAME).hdd
#	$(MAKE) -C src clean
#
#.PHONY: distclean
#distclean: clean
#	rm -rf limine ovmf
#	$(MAKE) -C src distclean
#