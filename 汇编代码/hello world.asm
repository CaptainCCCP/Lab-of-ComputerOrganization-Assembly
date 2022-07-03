.model small

.data
    strs DB 'hello world',13,10,'$'
.code
start:
    mov ax,@data
    mov ds,ax
    mov dx,offset strs
    mov ah,09h
    int 21h
    mov ah,4ch
    int 21h
end start