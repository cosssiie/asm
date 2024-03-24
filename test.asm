.model small
.stack 100h

.data
filename db 'test.in', 0
buffer db 255 dup(?) ; Буфер для зберігання прочитаних символів

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Відкриття файлу для читання
    mov ah, 3dh
    lea dx, filename
    mov al, 0 ; Режим читання
    int 21h
    jc file_error ; Перевірка помилки відкриття файлу
    mov bx, ax  

read_loop:
    ; Читання з файлу в буфер
    mov ah, 3fh
    mov cx, 255 ; Максимальна довжина для читання
    lea dx, buffer
    int 21h
    ; Перевірка на кінець файлу або помилку читання
    jc file_error
    jz file_end

    ; Виведення прочитаного тексту на екран
    mov ah, 09h
    lea dx, buffer
    int 21h
    jmp read_loop

file_end:
    ; Закриття файлу
    mov ah, 3eh
    mov bx, bx 
    int 21h

    jmp exit_program

file_error:
    mov ah, 09h
    lea dx, file_error_msg
    int 21h

exit_program:
    mov ah, 4ch
    int 21h

file_error_msg db 'File error!', 0

main endp
end main