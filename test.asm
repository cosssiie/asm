.model small
.stack 100h

.data
substring db 'a', 0 ; Підрядок, який потрібно знайти
filename db 'test.in', 0
buffer db 255 dup(?) ; Буфер для зберігання прочитаних символів
count dw ? ; Лічильник входжень підрядка
count_msg db '$'
newline db 0Dh, 0Ah, '$' ; Перехід на новий рядок для виведення

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

    mov cx, 0 ; Лічильник рядків

read_loop:
    ; Читання з файлу в буфер
    mov ah, 3fh
    mov cx, 255 ; Максимальна довжина для читання
    lea dx, buffer
    int 21h

    ; Перевірка на кінець файлу або помилку читання
    jc file_error
    cmp ax, 0 ; Перевірка на кінець файлу
    je file_end

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
    jmp read_loop

    ; Виведення прочитаного тексту на екран
end_of_line:
    mov ah, 09h
    lea dx, buffer
    int 21h

    ; Збільшення лічильника рядків
    inc cx
    jmp read_loop

file_end:
    ; Закриття файлу
    mov ah, 3eh
    int 21h

    ; Виведення кількості знайдених підрядків
    mov ah, 09h
    lea dx, count_msg
    int 21h
    mov ax, count
    call print_word

    ; Перехід на новий рядок
    mov ah, 09h
    lea dx, newline
    int 21h

    jmp exit_program

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
    ; Пошук підрядка в буфері
    mov si, offset buffer ; Вказівник на початок буфера
    mov di, offset substring ; Вказівник на початок підрядка
    mov cx, 0 ; Лічильник входжень підрядка в поточному буфері
    
find_next:
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
    jmp find_next ; Якщо символи збігаються, перевіряємо наступний символ

found_substring:
    inc cx ; Збільшуємо лічильник входжень
    mov di, offset substring ; Повертаємо вказівник на початок підрядка
    jmp end_find_next

end_find_next:
    add count, cx ; Додаємо кількість входжень підрядка в поточному буфері до загального лічильника
    ret

find_and_count_substring endp

print_word proc
    push ax
    push bx
    push cx
    push dx
    
    ; Конвертуємо кількість входжень у цифри та виводимо їх
    mov ax, count
    mov bx, 10
    mov cx, 0 ; Лічильник цифр
count_loop:
    xor dx, dx
    div bx ; Ділимо ax на 10
    add dl, '0' ; Конвертуємо залишок у символ
    push dx ; Зберігаємо цифру у стеку
    inc cx ; Збільшуємо лічильник цифр
    test ax, ax
    jnz count_loop ; Повторюємо, поки ax != 0
print_count:
    pop dx ; Відновлюємо цифру зі стеку
    mov ah, 02h
    int 21h ; Виводимо цифру
    loop print_count

    ; Виводимо пробіл
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Конвертуємо індекс рядка у цифри та виводимо їх
    mov ax, count
    mov bx, 10
    mov cx, 0 ; Лічильник цифр
line_index_loop:
    xor dx, dx
    div bx ; Ділимо ax на 10
    add dl, '0' ; Конвертуємо залишок у символ
    push dx ; Зберігаємо цифру у стеку
    inc cx ; Збільшуємо лічильник цифр
    test ax, ax
    jnz line_index_loop ; Повторюємо, поки ax != 0
print_index:
    pop dx ; Відновлюємо цифру зі стеку
    mov ah, 02h
    int 21h ; Виводимо цифру
    loop print_index

    ; Виводимо переведення строки
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_word endp

main endp
end main
