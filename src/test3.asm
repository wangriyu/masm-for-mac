datarea   segment  
  letter1   db   ?  
  digit1    db   ?  
  other1    db   ?  
  string   label  byte  
           max db 80   
           act db ?    
           str db 80 dup(?)  
print   db  13,10,'Please enter the string:','$'  
mess1   db  13,10, 'The total number of letter : ','$'  
mess2   db  13,10,'The total number of digit  : ','$'  
mess3   db  13,10,'The total number of other character : ','$'  
datarea   ends  
prognam  segment  
      assume  cs:prognam,ds:datarea  
start: push  ds  
       sub  ax,ax  
       push  ax  
       mov   ax,datarea  
       mov   ds,ax  
       mov   es,ax  
       mov   letter1,0  
       mov   digit1,0  
       mov   other1,0  
       lea   dx,print  
       mov   ah,09h    
       int   21h  
       lea   dx,string  
       mov   ah,0ah  
       int   21h  
       sub   ch,ch  
       mov   cl,[string+1]  
       lea   si,string+2  
digitseg:   
       mov   al,[si]  
       cmp   al,'0'  
       jb    otherseg     ;小于0为其他,0到9为数字  
       cmp   al,'9'  
       ja    letter1seg      
       inc   digit1  
       jmp   loop1  
letter1seg:   
       cmp   al,'A'       ;接上面，判断9之后，大于9，小于A为其他，A到Z为字母  
       jb    otherseg   ;jb  cf=1 （无符号数溢出）则转移，ja  cf与zf=1则转移  
       cmp   al,'Z'  
       ja    letter2seg   
       inc   letter1  
       jmp   loop1    
letter2seg:    
       cmp   al,'a'      ;接上面，判断Z之后，大于Z，小于a为其他，a到z为字母  
       jb    otherseg  
       cmp   al,'z'  
       ja    otherseg  
       inc   letter1  
       jmp   loop1  
otherseg:   
       inc   other1  
loop1:    
       inc   si  
       dec   cl  
       cmp   cl,0  
       jz    print1   
       jne   digitseg    ;重复分类过程    
print1:     
       lea   dx,mess1  
       mov   ah,09h  
       int   21h  
       mov   al,letter1  
       call  disp  
       lea   dx, mess2  
       mov   ah,09h  
       int   21h  
       mov   al,digit1  
       call  disp  
       lea   dx, mess3  
       mov   ah,09h  
       int   21h  
       mov   al,other1  
       call  disp  
exit:  
       mov   ah, 4ch  
       int  21h  
disp:                 ;十进制数形式显示AL中的内容.  
       mov  ah, 0  
       mov  bl, 10  
       div  bl        ;div 无符号:div src 16位操作:商ax=(dx,ax)/src,余数dx  
       add  al, 30h    ;比如说al=15h,即21，表示letter数量，然后，这个过程就是，ax=0015h(21),除以bl，bl值为10  
       mov  dl, al      ;则除完了的结果为2余1，则ah=01,al=02,即ax=0102h;,那么al+30h即为表示该数字的ASCII码值，因为0的ASCII值为30h  
       mov  bh, ah       ;则ax=0132h,dl=32,bh=01;  
       mov  ah, 02h      ;显示输出dx,则显示32码对应的数字，2  
       int  21h             
       mov  al, bh        ;把01给al,然后算出ASCII码，然后给dx，然后显示  
       add  al, 30h  
       mov  dl, al        ;除数B有 8位和16位两种，保存在一个reg寄存器里 或是内存单元中。  
   
                          ;被除数A 默认存放在AX中（16位以内） 或 AX和DX中（32位，DX存放高16位，AX存放低16位）  
   
                          ;结果： 如果除数B是8位，那么除法的结果AL保存商，AH保存余数，  
                          ;如果除数B是16位，那么除法的结果 AX保存商，DX保存余数。  
       mov  ah, 02h  
       int  21h       
       ret  
;---------------------------------------  
;****************************************         
prognam   ends  
       end   start 