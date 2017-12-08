;--------------------------------------------;
;Name:平均数计算
;Desccription:连续输入十个10以下的数，程序计算去掉一个最小数，
;去掉一个最大数后八个数的平均值，从显示器显示出来，结果保留3位小数
;--------------------------------------------;
DATA    SEGMENT
  BUF DB ?
  ORG 10H
  TABLE DB ?
  BUF1 DB 'PLEASE ENTER 10 NUMBERS$'
  BUF2 DB 'THE AVERAGE IS$'
DATA ENDS

CODE SEGMENT 
  ASSUME CS:CODE,DS:DATA
START:
  MOV AX,DATA
  MOV DS,AX
  LEA DX,BUF1
  MOV AH,9
  INT 21H   ;显示提示信息‘PLEASE ENTER 10 NUMBERS’
  MOV AH,02H
  MOV DL,0AH
  INT 21H;换行
  MOV CX,10
  LEA DI,BUF
  LP1: ;连续输入10个数
  MOV AH,1
  INT 21H
  SUB AL,30H   ;asc码转bcd码
  MOV [DI],AL
  INC DI
  MOV DL,20H   ;输入中插入空格
  MOV AH,02H
  INT 21H 
  LOOP LP1
  MOV CH,10
  DEC CH
LOP0:
  MOV SI,OFFSET BUF  ;冒泡排序法
  MOV CL,CH
  XOR BL,BL
LOP1:
  MOV AL,[SI]
  CMP AL,[SI+1]
  JLE NEXT
  XCHG AL,[SI+1]
  MOV [SI],AL
  OR BL,01H
NEXT:
  INC SI
  DEC CL
  JNZ LOP1
  AND BL,BL
  JZ STOP 
  DEC CH
  JNZ LOP0
STOP:
  MOV SI,OFFSET BUF
  MOV DI,OFFSET TABLE 
  INC SI   ;从第二个数开始存数据
  MOV CX,8
  MOV AX,0
LOP3:
  ADD AL,[SI]   ;相加得到和
  INC SI
  LOOP LOP3
  MOV [DI],AL  ;和存入DL
  MOV CL,8  ;CL=8
  DIV CL   ;AX/CL 商>AL 余数>AH
  INC DI
  MOV [DI],AL  ;商
  INC DI 
  MOV [DI],AH  ;余数
  MOV AL,AH  ;余数存入AL
  MOV AH,0
  MOV CX,3
LOP4:
  MOV BL,10  
  MUL BL   ;余数x10  
  MOV BH,8  
  DIV BH    ;除8求商求余   
  INC DI   
  MOV [DI],AL   
  INC DI 
  MOV [DI],AH   
  MOV AL,AH  
  MOV AH,0 
  LOOP LOP4    
  MOV DI,OFFSET TABLE     
  MOV AH,02H      ;换行   
  MOV DL,0AH  
  INT  21H        
  LEA DX,BUF2   
  MOV AH,9     
  INT 21H     ;显示提示信息‘THE AVERAGE IS’  
  MOV AH,02H    
  MOV DL,0AH    
  INT  21H    ;换行     
  MOV DL,[DI+1]   ;依次显示数据  
  ADD DL,30H      ;个位数   
  MOV AH,2  
  INT 21H     
  MOV DL,2EH    ;小数点   
  MOV AH,2  
  INT 21H     
  MOV DL,[DI+3]   ;第一位小数   
  ADD DL,30H  
  MOV AH,2  
  INT 21H     
  MOV DL,[DI+5]   ;第二位小数   
  ADD DL,30H  
  MOV AH,2  
  INT 21H     
  MOV DL,[DI+7]   ;第三位小数   
  ADD DL,30H  
  MOV AH,2  
  INT 21H     
  MOV AH,4CH    ;返回DOS    
  INT 21H 

CODE ENDS   
END START 
