.model small
.stack 100h
.data
    tb db 10, 10, 13, 'mang ban dau la: 11 22 33 1 4 21 99 0 8 121$'
    tb1 db 10, 10, 13, 'so luong cac so chia het 11 cho  trong mang la: $'
    tb2 db 10, 13, 10, 'tong cac so chia het cho 11 trong mang la: $'
    array db 11, 22, 33, 1, 4, 21, 99, 3, 8, 121
    count dw ?         ;bien dem so luong
    sum dw ?           ;bien tinh tong
.code
main proc             
    ;nhap data
    mov ax, @data
    mov ds, ax                                         
                                             
    mov cx, 10              ;khoi tao bien dem de lap
    lea si, array           ;truyen dia chi mang vao si
    mov bx, 11              ;khoi tao so chia
    
    lea dx, tb
    mov ah, 9
    int 21h
    
    ;lap mang
    lapMang:
        mov dx, 0           ;khoi tao du = 0
        mov ax, [si]        ;truyen gia tri cua array[0] vao ax
        xor ah, ah          ;clear ah
        div bx              ;chia 11
        cmp dx, 0           ;so sanh du cua phep chia voi 0
        je cong             ;neu dx = 0 thi tinh tong
        jmp continue        ;tiep tuc vong lap
        cong:
            mov ax, [si]    ;gan gtri cho ax
            xor ah, ah      ;clear ah
            add sum, ax     ;tinh tong
            inc count       ;tang bien dem       
        continue:
            inc si
            loop lapMang       
    
    ;in ra ket qua
    call printResult
        
    ;dung chuong trinh
    mov ah, 4ch
    int 21h
main endp

;ham in kq
printResult proc 
    mov bx, 10              ;khoi tao so chia = 10
    ;in so luong
    lea dx, tb1
    mov ah, 9
    int 21h
    
    mov ax, count           ;gan ax = count
    mov cx, 0               ;khoi tao cx = 0
    call printNumber
    
    ;in tong
    lea dx, tb2
    mov ah, 9
    int 21h 
       
    mov ax, sum             ;gan ax = sum
    mov cx, 0               ;khoi tao cx = 0
    call printNumber
    ret
printResult endp

printNumber proc
    ;lap1 de push vao stack
    lap1:
        mov dx, 0
        div bx
        push dx
        inc cx
        cmp ax, 0
        jnz lap1
        
    ;lap2 de in kq
    lap2:
        pop dx
        add dx, '0'
        mov ah, 2
        int 21h
    loop lap2
    ret
printNumber endp
end 
