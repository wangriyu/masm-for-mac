;换行（宏定义）
CRLF MACRO
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV AH, 2
    MOV DL, 0AH
    INT 21H
ENDM

;测试
TESTMess MACRO
    mov ah, 09h
    lea dx, messt
    int 21h
ENDM

DATAS SEGMENT
    mess1 db 'Please input name:', '$'
    mess2 db 'Please input telephone number:', '$'
    mess3 db 'Do you want to search a telephone number?(y/n)', '$'
    mess4 db 0dh, 0ah, 'what is the name?', '$'
    mess5 db 'Not find', 0dh, 0ah, '$'
    mess6 db 'How much set of data you want to store:', '$'
    messt db 'test', 0dh, 0ah, '$'

    stokin1 label byte
    max1   db 21
    act1   db ?
    stokn1 db 21 dup(?)

    stokin2 label word
    max2   db 9
    act2   db ?
    stokn2 db 9 dup(?)

    numtable   db 50 dup(28 dup(?))
    name_count dw 0
    endaddr    dw ?
    swapped    dw ?
    totalnum   dw ?
    savenp     db 28 dup(?), 0dh, 0ah, '$'
    searchaddr dw ?
    flag       db ?
    flagb      db ?
    show       db 'name                phone', 0dh, 0ah, '$'
DATAS ENDS

STACKS SEGMENT
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATAS, ES:DATAS, SS:STACKS
START:
    mov ax, DATAS
    mov ds, ax
    mov es, ax
    lea di, numtable   ;di must be protected  
    lea dx, mess6      ;显示信息，请输入想存入的电话号码总数  
    mov ah, 09
    int 21h
    mov bx, 0
newchar:
    mov ah, 1          ;从键盘接收totalnum, 并回显AL=输入字符  
    int 21h
    sub al, 30h        ;ascii to binary
    jl next            ;jump if<0
    cmp al, 9          ;is it >9?
    jg next            ;yes jump
    cbw                ;byte in AL to word in AX
    xchg ax, bx        ;交换
    mov cx, 10         ;put 10 dec in CX  
    mul cx             ;number times 10 （DX, AX）<-(AX)*src  
    xchg ax, bx        ;交换
    add bx, ax         ;add digit to number
    jmp newchar        ;get next digit
next:
    mov totalnum, bx
    cmp totalnum, 0
    jle exit
    CRLF
a10:
    lea dx, mess1        ;显示请输入名字  
    mov ah, 09
    int 21h
    call input_name
    inc  name_count
    call stor_name
    lea dx, mess2        ;显示请输入电话  
    mov ah, 09
    int 21h
    call inphone
    call stor_phone
    cmp name_count, 0
    je exit
    mov bx, totalnum
    cmp name_count, bx   ;输入与之前输入总数相等的姓名，电话  
    jnz a10
    call name_sort
    call printAll
a20:
    lea dx, mess3        ;显示是否需要查找电话号码  
    mov ah, 09  
    int 21h  
    mov ah, 08           ;键盘输入，无回显，检测ctrl-break 或 Ctrl-C, AL=输入字符  
    int 21h  
    cmp al, 'y'  
    jz  a30  
    cmp al, 'n'  
    jz  exit  
    jmp a20
a30:
    mov ah, 09  
    lea dx, mess4         ;显示询问名字  
    int 21h  
    call input_name  
a40:
    call name_search  
    ;call printline  
    ;dec flag  
    ;sub flag, 0          ;要是没结束的话
    ;jnz  a40  
    jmp a20  
exit:
    mov ax, 4c00h;
    int 21h
;--------------------------------------------------------------------  
input_name proc near
    mov ah, 0ah  
    lea dx, stokin1  
    int 21h
    CRLF
    sub bh, bh
    mov bl, act1
    mov cx, 21 
    sub cx, bx            ;dst<-dst-src, cx为计数功能寄存器  
b10:
    mov stokn1[bx], ' '   ;补全空格
    inc bx  
    loop b10  
;b20:  
    ; call name_search
    ; sub flag, 0
    ; jz b30
    ; lea dx, mess5
    ; mov ah, 09
    ; int 21h
; b30:  
    ret  
input_name endp
;--------------------------------------------------------------------  
stor_name proc near
    lea  si, stokn1
    mov  cx, 20
    rep  movsb
    ret
stor_name endp
;--------------------------------------------------------------------  
inphone proc near
    mov ah, 0ah
    lea dx, stokin2
    int 21h
    CRLF
    sub bh, bh
    mov bl, act2
    mov cx, 9
    sub cx, bx
c10:
    mov stokn2[bx], ' '
    inc bx
    loop c10
    ret
inphone endp
;--------------------------------------------------------------------  
stor_phone proc near
    lea si, stokn2
    mov cx, 8
    rep movsb           ;movs 串传送指令 cmps 串比较操作  
    ret
stor_phone endp
;--------------------------------------------------------------------  
name_sort proc near
    sub di, 28
    mov endaddr, di
c1:
    mov swapped, 0
    lea si, numtable
c2:
    mov cx, 20  
    mov di, si  
    add di, 28  
    mov ax, di  
    mov bx, si   ;cmpsb si-di  movsb di<-si  
    repz cmpsb   ;repz 当为0时重复串操作；repe 当相等时重复串操作；rep 重复串操作直至计数寄存器count reg 的内容为0为止  
    jbe c3       ;CF与ZF=1，小于等于则转移  
;change order
    mov si, bx
    lea di, savenp
    mov cx, 28
    rep movsb
    mov cx, 28
    mov di, bx
    rep movsb
    mov cx, 28
    lea si, savenp
    rep movsb
    mov swapped, 1
c3:
    mov si, ax
    cmp si, endaddr
    jb c2                 ;CF=1，则转移，小于等于则转移
    cmp swapped, 0
    jnz c1                ;结果不为0则转移
    ret
name_sort endp
;--------------------------------------------------------------------
printAll proc near
    lea si, numtable
    mov ah, 09  
    lea dx, show  
    int 21h  
d1:
    lea di, savenp
    mov cx, 14
    rep movsw
    mov ah, 09h
    lea dx, savenp
    int 21h
    dec name_count
    jnz d1
    ret
printAll endp
;--------------------------------------------------------------------
name_search proc near
    lea  bx, numtable
    mov  flag, 0
    ;mov  flagb, 0
d:
    ;mov  flag, 0
    ;mov  flagb, 0
    mov  cx, 20
    lea si, stokn1  
    mov  di, bx  
    repz cmpsb  
    jz  d2  
    ;jb  dexit  
    add bx, 28            ;下一条  
    cmp  bx, endaddr     
    jbe  d                ;未结束，继续找  
    ;add flagb, flag  
    sub flag, 0           ;要是没有找到的话  
    jz  nof
    jmp  dexit            ;结束，退出  
d2:
    mov searchaddr, bx  
    ;mov flag, 1          ;标志找到了  
    inc flag  
    call printline  
    ; dec flag  
    ;sub flag, 0          ;要是没结束的话  
    add bx, 28            ;下一条  
    cmp  bx, endaddr
    jbe  d                ;未结束，继续找  
    jmp  dexit            ;结束，退出  
    jnz  d  
nof: 
    lea dx, mess5
    mov ah, 09
    int 21h
dexit:
    ret
name_search endp
;--------------------------------------------------------------------  
printline proc near
    sub flag, 0           ;要是没有找到的话  
    jz  no  
p10:
    mov ah, 09  
    lea dx, show  
    int 21h  
    mov cx, 28  
    mov si, searchaddr  
    lea di, savenp  
    rep movsb  
    lea dx, savenp  
    mov ah, 09  
    int 21h
    jmp fexit
no:
    lea dx, mess5
    mov ah, 09
    int 21h
fexit:
    ret
printline endp

CODES ENDS
END START
