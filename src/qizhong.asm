diswmed macro hexdata
      local diswmed1
      push ax
      push bx
      push cx
      push dx 
      mov bx,hexdata
      mov cx,0404h
diswmed1:rol bx,cl
      mov al,bl
      and al,0fh
      call change
      push dx
      mov ah,2
      mov dl,al
      int 21h
      pop dx
      dec ch
      jnz diswmed1
      pop dx
      pop cx
      pop bx
      pop ax
endm

DATAS SEGMENT
    ;此处输入数据段代码 
    string1 db '平均数为：','$'
DATAS ENDS
STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    
    count = 10
    array dw count dup(0)
    wtemp dw ?
    wmed  dw ?
     
    mov cx,count
    mov bx,offset array
    again1:   
    call read
    mov [bx],ax
    inc bx
    inc bx
    call linewrap
    loop again1
    
    again2:
    mov ax,[bx]
    mov wtemp,ax   
    call write
    inc bx
    inc bx
    call linewrap
    loop again2
    
    mov ax,count
    push ax
    mov ax,offset array
    push ax
    call mean
    add sp,4
    
    mov wmed,ax
    diswmed wmed
   
    MOV AH,4CH
    INT 21H  
    read proc
         push bx
         push cx
         push dx
         xor bx,bx
         xor cx,cx;清空
         mov ah,1
         int 21h  
         cmp al,'+'
         jz read1
         cmp al,'-'
         jnz read2
         mov cx,-1
   read1:mov ah,1;继续输入字符
         int 21h
   read2:cmp al,'0'
         jb read3
         cmp al,'9'
         ja read3;不是数字则退出输入
         sub al,30h
         shl bx,1
         mov dx,bx
         shl bx,1
         shl bx,1
         add bx,dx
         mov ah,0
         add bx,ax
         jmp read1  
   read3:cmp cx,0
         jz read4
         neg bx
   read4:mov ax,bx
         pop dx
         pop cx
         pop bx
         ret
    read endp
    write proc
          push ax
          push bx
          push dx
          mov ax,wtemp
          test ax,ax
          jnz write1
          mov dl,'0'
          mov ah,2
          int 21h
          jmp write5
   write1:jns write2
          mov bx,ax
          mov dl,'-'
          mov ah,2
          int 21h
          mov ax,bx
          neg ax
   write2:mov bx,10
          push bx
   write3:cmp ax,0
          jz write4
          sub dx,dx
          div bx
          add dl,30h
          push dx
          jmp write3
   write4:pop dx
          cmp dl,10
          je write5
          mov ah,2
          int 21h
          jmp write4
   write5:pop dx
          pop bx
          pop ax
          ret
    write endp
    mean proc
         push bp
         mov bp,sp
         push bx
         push cx
         push dx
         push si
         push di
         mov bx,[bp+4]
         mov cx,[bp+6]
         xor si,si
         mov di,si
   mean1:mov ax,[bx]
         cwd
         add si,ax
         adc di,dx
         inc bx
         inc bx
         loop mean1
         mov ax,si
         mov dx,di
         mov cx,[bp+6]
         idiv cx
         pop di
         pop si
         pop dx
         pop Cx
         pop bx
         pop bp
         ret
    mean endp 
    linewrap proc;回车换行
             push ax
             push dx
             mov ah,2
             mov dl,0dh
             int 21h
             mov ah,2
             mov dl,0ah
             int 21h
             pop dx
             pop ax
             ret
    linewrap endp  
    change proc
           and al,0fh
           cmp al,9
           jbe change1
           add al,37h
           ret
     change1:
           add al,30h
           ret
     change endp
CODES ENDS
    END START
