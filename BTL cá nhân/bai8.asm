.model small
.stack 100h
.data
    tb1 db "Nhap so thap phan: $"
    tb2 db 10, 10, 13, "So o dang thap luc phan(16) la: $"
    num db 10 dup("$")
.code
    main proc
        mov ax, @data
        mov ds, ax
        
        ;nhap so 
        lea dx, tb1
        mov ah, 9
        int 21h
        
        lea dx, num
        mov ah, 10
        int 21h            
        
        lea dx, tb2
        mov ah, 9  
        int 21h      
        
        ;chuyen xau sang so
        mov ax, 0
        mov bx, 10
        
        xor cx, cx
        mov cl, num + 1
        lea si, num + 2
        
        thapPhan:
            mul bx
            mov dl, [si]
            sub dl, '0'
            add ax, dx
            inc si
            loop thapPhan
        
        ;chuyen tu he 10 sang 16   
        mov bl, 16
        mov cx, 0
        
        
        
        
                     
        thapLucPhan: 
            div bl
            push ax
            inc cx
            cmp al, 0
            je kq
            mov ah, 0
            jmp thapLucPhan
        
        ;in kq
        kq:
            inKq:
                pop ax
                mov dl, ah
                cmp dl, 10
                je hexA
                cmp dl, 11
                je hexB
                cmp dl, 12
                je hexC
                cmp dl, 13
                je hexD
                cmp dl, 14
                je hexE
                cmp dl, 15
                je hexF
                
                add dl, '0'
                jmp print
                           
                hexA:
                    mov dl, 'A'
                    jmp print
                    
                hexB:
                    mov dl, 'B'
                    jmp print
                    
                hexC:
                    mov dl, 'C'
                    jmp print
                    
                hexD:
                    mov dl, 'D'
                    jmp print
                    
                hexE:
                    mov dl, 'E'
                    jmp print
                    
                hexF:
                    mov dl, 'F'
                    jmp print
                                   
                print:
                    mov ah, 2
                    int 21h
                
                loop inKq 
                
        ;dung chuong trinh
        mov ah, 4ch
        int 21h
    main endp
end
            
            
            