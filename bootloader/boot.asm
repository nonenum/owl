;; Copyright (c) 2025 nonenum. All Rights Reserved.

org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

jmp short start
nop

bdb_oem:  db 'MSWIN4.1'
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster:  db 1
bdb_reserved_sectors: dw 1
bdb_fat_count:  db 2
bdb_dir_entries_count:  dw 0x0E0
bdb_total_secotrs:  dw 2880
bdb_media_descriptor_type: dw 0x0F0
bdb_sectors_per_fat:  dw 9
bdb_sectors_per_track:  dw 18
bdb_heads:  dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

ebr_drive_number: db 0
db 0
ebr_signature:  db 0x29
ebr_volume_id:  db 0x20 0x25 0x12 0x29
ebr_volume_label: db 'NONENUM OWL'
ebr_system_id:  db 'FAT12   '

start:
  jmp main

;; Params(ds:si)
puts:
  push si
  push ax

.loop:
  lodsb
  or al, al
  jz .done

  mov ah, 0x0E
  mov bh, 0
  int 0x10

  jmp .loop

.done:
  pop ax
  pop si
  ret

main:
  mov ax, 0
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00

  mov [ebr_drive_number], dl
  mov ax, 1
  mov cl, 1
  mov bx, 0x7E00

  call disk_read

  mov si, msg_hw
  call puts

  cli
  hlt

disk_error:
  mov si, msg_read_err
  call puts
  jmp wait_key_reboot

wait_key_reboot:
  mov ah, 0
  int 0x16
  jmp 0x0FFFF:0

.halt:
  cli
  hlt

;; Params(ax)
;; Returns(cx[0-5], cx[6-15], dh)
lba_to_chs:
  push ax
  push dx

  xor dx, dx
  div word [bdb_sectors_per_track]
  inc dx
  mov cx, dx

  xor dx, dx
  div word [bdb_heads]
  mov dh, dl
  mov ch, al
  shl ah, 6
  or cl, ah

  pop ax
  mov dl, al
  pop ax

  ret

;; Params(ax, cl, dl, es:bx)
disk_read:
  push ax
  push bx
  push cx
  push dx
  push di

  push cx
  call lba_to_chs
  pop ax

  mov ah, 0x02
  mov di, 3

.retry:
  pusha
  stc
  int 0x13
  jnc .done
  
  popa
  call disk_reset

  dec di
  test di, di
  jnz .retry

.fail:
  jmp disk_error

.done:
  popa

  pop ax
  pop bx
  pop cx
  pop dx
  pop di

  ret

;; Params(dl)
disk_reset:
  pusha
  mov ah, 0
  
  stc
  int 0x13
  jc disk_error
  popa

  ret

msg_hw: db 'Hello world', ENDL, 0
msg_read_err: db 'Failed to read from disk.', ENDL, 0

times 510-($-$$) db 0
dw 0x0AA55
