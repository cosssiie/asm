.model small
.stack 100h

.data
filename db 'test.in', 0
buffer db 256 dup(?) ; Буфер для зберігання прочитаних символів
substring db 'a', 0 ; Підрядок, який потрібно знайти
count dw ? ; Лічильник входжень підрядка
count_msg db 'Count of substring: $'

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

    ; Ініціалізація лічильника
    mov count, 0

read_loop:
    ; Читання з файлу в буфер
    mov ah, 3fh
    mov cx, 256 ; Максимальна довжина для читання
    lea dx, buffer
    int 21h
    ; Перевірка на кінець файлу або помилку читання
    jc file_error
    jz file_end

    ; Перевірка на символ кінця рядка
    mov si, offset buffer
    mov di, cx
    dec di
    mov al, [si] ; Отримати перший символ у буфері
    add si, di   ; Збільшити адресу на значення в di
    cmp al, 0Dh ; Перевірка на символ '\r'
    je end_of_line
    cmp al, 0Ah ; Перевірка на символ '\n'
    je end_of_line

    ; Якщо це не кінець рядка, продовжуємо обробку
    call find_and_count_substring

    ; Виведення прочитаного тексту на екран
    mov ah, 09h
    lea dx, buffer
    int 21h
    jmp read_loop

end_of_line:
    ; Обробка кінця рядка
    jmp read_loop ; Пропускаємо обробку рядка і переходимо до наступного рядка

file_end:
    ; Закриття файлу
    mov ah, 3eh
    mov bx, bx 
    int 21h

    ; Виведення кількості знайдених підрядків
    mov ah, 09h
    lea dx, count_msg
    int 21h

    mov ax, count
    call print_word

file_error:
    ; Обробка помилки читання файлу
    mov ah, 09h
    lea dx, file_error_msg
    int 21h

exit_program:
    mov ah, 4ch
    int 21h

file_error_msg db 'Помилка файлу!', 0

find_and_count_substring proc
    mov si, offset buffer ; Вказівник на початок буфера
    mov di, offset substring ; Вказівник на початок підрядка
    mov cx, 0 ; Лічильник входжень підрядка в поточному буфері

find_next:
    ; Пошук підрядка в буфері
    mov ah, [di] ; Завантажуємо поточний символ підрядка
    cmp ah, 0 ; Перевіряємо, чи досягнутий кінець підрядка
    je end_find_next
    lodsb ; Завантажуємо поточний символ з буфера
    cmp al, ah ; Порівнюємо символ з буфера з поточним символом підрядка
    jne mismatch
    inc di ; Переходимо до наступного символу підрядка
    cmp di, offset substring + 1 ; Перевіряємо, чи досягли кінця підрядка
    je found_substring ; Якщо досягнуто, це означає, що підрядок знайдено
    jmp check_substring

mismatch:
    mov di, offset substring ; Повертаємо вказівник на початок підрядка
    inc si ; Переходимо до наступного символу у буфері
    jmp find_next

check_substring:
    mov ah, [di] ; Завантажуємо поточний символ підрядка
    cmp ah, 0 ; Перевіряємо, чи досягнутий кінець підрядка
    je found_substring ; Якщо досягнуто, це означає, що підрядок знайдено
    lodsb ; Завантажуємо наступний символ з буфера
    cmp al, ah ; Порівнюємо символи
    jne mismatch ; Якщо символи не збігаються, переходимо до пошуку наступного входження

found_substring:
    inc cx ; Збільшуємо лічильник входжень
    mov di, offset substring ; Повертаємо вказівник на початок підрядка
    jmp find_next

end_find_next:
    add count, cx ; Додаємо кількість входжень підрядка в поточному буфері до загального лічильника
    ret
find_and_count_substring endp

print_word proc
    push ax
    push dx

    mov dx, 0
    mov cx, 10
next_digit:
    xor dx, dx
    div cx
    add dl, '0'
    push dx
    test ax, ax
    jnz next_digit

print_loop:
    pop dx
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop ax
    ret
print_word endp

main endp
end main
