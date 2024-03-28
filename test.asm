.model small
.stack 100h

.data
substring db 'aa', 0 ; Підрядок, який потрібно знайти
filename db 'test.in', 0
buffer db 255 dup(?) ; Буфер для зберігання прочитаних символів
result_array dw 100 dup(?) ; Масив для зберігання результатів
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

    ; Пошук підрядка в поточному буфері та підрахунок кількості входжень
    call find_and_count_substring

    ; Збереження результатів в масиві
    mov ax, count
    mov result_array, ax ; Зберігаємо кількість входжень підрядка
    mov ax, cx
    mov result_array[2], ax ; Зберігаємо номер рядка

    ; Перехід до наступного результату в масиві
    add result_array, 4 ; Розміщення наступного результату в масиві

    jmp read_loop

file_end:
    ; Закриття файлу
    mov ah, 3eh
    int 21h

    ; Сортування результатів за кількістю входжень підрядка
    call bubble_sort

    ; Виведення відсортованих результатів
    jmp print_sorted_results

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
    ; Пошук підрядка в буфері та підрахунок кількості входжень
    xor cx, cx ; Очищуємо лічильник входжень
    mov si, offset buffer ; Вказівник на початок буфера
    mov di, offset substring ; Вказівник на початок підрядка

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
    jmp find_next

end_find_next:
    mov count, cx ; Зберігаємо кількість знайдених входжень в лічильнику
    ret

find_and_count_substring endp

bubble_sort proc
    ; Сортування масиву result_array методом бульбашкового сортування
    mov cx, 100 ; Кількість елементів у масиві
    mov si, offset result_array ; Початок масиву
outer_loop:
    dec cx ; Зменшуємо лічильник
    jz done_sorting ; Якщо лічильник став нульовим, сортування завершено
    mov di, si ; Копіюємо початкову адресу масиву в di
    mov ax, [di] ; Завантажуємо перший елемент масиву
inner_loop:
    cmp ax, [di + 4] ; Порівнюємо поточний елемент з наступним
    jbe not_swap ; Якщо поточний елемент менший або рівний наступному, не проводимо обмін
    xchg ax, [di + 4] ; Якщо поточний елемент більший за наступний, проводимо обмін
    mov [di], ax ; Зберігаємо результат обміну в поточному місці масиву
not_swap:
    add di, 4 ; Переходимо до наступного елементу
    loop inner_loop ; Повторюємо внутрішній цикл, поки не пройдемо всі елементи
    jmp outer_loop ; Повторюємо зовнішній цикл
done_sorting:
    ret

bubble_sort endp

print_sorted_results proc
    ; Виведення відсортованих результатів
    mov cx, 100 ; Кількість елементів у масиві
    mov si, offset result_array ; Початок масиву
printing_loop:
    cmp cx, 0 ; Перевірка на кінець масиву
    je print_done ; Якщо кінець масиву, завершуємо виведення
    mov ax, [si] ; Завантажуємо кількість входжень підрядка
    call print_word ; Виводимо кількість входжень
    mov dx, offset count_msg ; Виводимо роздільник
    mov ah, 09h
    int 21h
    mov ax, [si + 2] ; Завантажуємо номер рядка
    call print_word ; Виводимо номер рядка
    mov dx, offset newline ; Перехід на новий рядок
    mov ah, 09h
    int 21h
    add si, 4 ; Переходимо до наступного елементу масиву
    loop print_loop ; Повторюємо цикл для інших елементів масиву
print_done:
    ret

print_sorted_results endp

print_word proc
    ; Виведення числа на екран
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10 ; Дільник
    mov cx, 0 ; Лічильник цифр
    
count_loop:
    xor dx, dx
    div bx ; Ділимо ax на 10
    add dl, '0' ; Конвертуємо залишок у символ
    push dx ; Зберігаємо цифру у стеку
    inc cx ; Збільшуємо лічильник цифр
    test ax, ax
    jnz count_loop ; Повторюємо, поки ax != 0

print_loop:
    pop dx ; Відновлюємо цифру зі стеку
    mov ah, 02h
    int 21h ; Виводимо цифру
    loop print_loop

    ; Виведення пробілу
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_word endp

main endp
end main
