.model small
.stack 100h

.data
buffer db 256 dup (?)  ; Буфер для зберігання введеного рядка
prompt db 'Write a message: $'  ; Повідомлення для користувача

.code
start:
    mov ax, @data
    mov ds, ax

    ; Виведення повідомлення для користувача
    mov ah, 09h         
    lea dx, prompt      
    int 21h             ; Виклик DOS для виведення повідомлення

    ; Зчитування рядка з клавіатури
    mov ah, 01h   
    lea dx, buffer      
    int 21h       ; Виклик DOS для введення символу

    ; Виведення введеного символу на екран
    mov ah, 02h         
    mov dl, byte ptr [buffer]  
    int 21h             ; Виклик DOS для виведення символу

    ; Завершення програми
    mov ah, 4Ch         ; DOS function for program termination
    int 21h             ; Виклик DOS для завершення програми

end start
