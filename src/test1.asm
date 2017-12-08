DATAS SEGMENT

DATAS ENDS

STACKS SEGMENT

STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;
    mov dl, 10h
    mov cx, 15
next1: push cx
    mov cx, 16
next: mov ah, 02h
    int 21h
    inc dl
    push dx
    mov dl, 20h
    mov ah, 02h
    int 21h
    pop dx
    loop next
    push dx
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h
    pop dx
    pop cx
    loop next1
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

