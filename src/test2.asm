;换行（宏定义）
CRLF MACRO
    MOV AH, 2
    MOV DL,0DH
    INT 21H
    MOV AH, 2
    MOV DL, 0AH
    INT 21H
ENDM
;------------------------------------------

;打印字符串（宏定义）
S_SHOW MACRO STRING
    MOV AH, 9
    MOV DX, OFFSET STRING
    INT 21H
ENDM
;-----------------------------------------

;接收一个输入（宏定义）
S_IN MACRO BUFF
    MOV AH, 10
    MOV DX, OFFSET BUFF
    INT 21H
ENDM
;-------------------------------------------

DATAS SEGMENT
    wordH     DB 'H', '$'
    MESS1 DB 'match!', 0DH, 0AH, '$'
    MESS2 DB 'no match!', 0DH, 0AH, '$'
    MESS11 DB 'indexof key:', 0, '$'
    MESS3 DB 'Enter key:', 0, '$'
    MESS4 DB 'Enter Sentence:', 0, '$'
    KEY DB 20, ?, 20 DUP(?)
    SENTENCE DB 60, ?, 60 DUP(?)
DATAS ENDS

STACKS SEGMENT
STACKS ENDS

CODES SEGMENT  
    ASSUME CS:CODES, DS:DATAS, SS:STACKS
START:
    PUSH AX
    SUB AX, AX
    PUSH BX
    SUB BX, BX
    MOV AX, DATAS
    MOV DS, AX
    ;
    S_SHOW MESS3
    S_IN KEY
    CRLF
GO:
    sub dx, dx
    S_SHOW MESS4
    S_IN SENTENCE
    CRLF
    MOV CH, [SENTENCE+1]-[KEY+1]
    INC CH
    MOV BX, OFFSET SENTENCE+2
REBEGIN:
    MOV CL, KEY+1
    MOV SI, OFFSET KEY+2
    MOV DI, BX
EXE:
    CMP CH, CL
    JB EXIT0
    PUSH DI
    PUSH SI
    MOV DI, WORD PTR[DI]
    MOV SI, WORD PTR[SI]
    CMP DI,SI
    JE MATCH1
    DEC CH
    INC CH
    JE EXIT1
    DEC CH
    INC BX
    JMP REBEGIN
MATCH1:
    DEC CL
    JE MATCH
    INC DI
    INC SI
    JMP EXE
MATCH:
    S_SHOW MESS1
    S_SHOW MESS11
    MOV DX, OFFSET sentence
    push bx
    sub Bx, dx
    sub bx, 2
    mov dx, bx
    push dx
    shr dx, 1
    shr dx, 1
    shr dx, 1
    shr dx, 1
    cmp dx, 9
    ja anine2
a3:
    cmp dx, 9
    jb bnine2
EXIT0:
    S_SHOW MESS2
    CMP CH, CL
    jb EXIT
EXIT1:
    DEC CH
    INC CH
    JE EXIT
a4:
    mov ah, 02h
    mov al, 40h
    int 21h
    pop dx
    and dx, 0fh
    cmp dx, 9
    ja anine1
a1:
    cmp dx, 9
    jb bnine1
a2:
    mov ah, 02h
    mov al, 40
    int 21h
    lea dx, wordH
    mov ah, 09
    int 21h
    CRLF
    pop bx
    JMP EXIT
anine1:
    add dx, 38h
    jmp a1
bnine1:
    add dx, 31h
    jmp a2
anine2:
    add dx, 37h
    jmp a3
bnine2:
    add dx, 30h
    jmp a4
EXIT:
    CRLF
    mov ax, 4c00h
    int 21h

CODES ENDS
END  START
