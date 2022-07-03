enterline macro		;定义回车换行的宏指令
	mov dl,13
	mov ah,2
	int 21h
	mov dl,10
	mov ah,2
	int 21h
endm
;_______________________________________________________
DATAS SEGMENT
    ;此处输入数据段代码  
STRING0 db "please input a string:$"
STRING2 DB "THE BIGGEST ASCII IS:$"
INPUTSTR DB 50,?,50 dup('$')
;能容纳字符个数;实际接受的字符个数;字符串缓冲区
ERROR DB "ERRORERROR$"
output db 'LENGTH is$:' 
input db 'Please Input Number:$'
flag db 0
flag1 db 0
NUM DB 0
NUMIN DB 4,?,4 DUP(0)
;_______________________________________________________
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
    DW 50 DUP(0)
STACKS ENDS
;_______________________________________________________
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,STACKS
    MOV SS,AX
    MOV SP,100
    ;此处输入代码段代码
    LEA dx,STRING0  ;提示
    mov ah,09h
    int 21h
    enterline
    ;=========
    mov ah,0ah  ;输入字符串
    lea dx,INPUTSTR
    int 21h
    ;=========
    XOR AX,AX
	XOR BX,BX
    MOV BX,40        ;边界判断
    
    LEA si,INPUTSTR
    MOV AX,[SI+1]
    MOV AH,0
    CMP AX,BX
    JA ERR
    MOV BX,15
    CMP AX,BX
    JB ERR
    ;=========
    ENTERLINE
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL LEN;长度1
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL REV;逆序2
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL JUDGE;非字母3
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL BIGASC;最大asc4
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL INT1;指定输出5
;_______________________________________________________
JMP STOP
ERR:
	enterline
	MOV DX,OFFSET ERROR;报错
	MOV AH,09H
	INT 21H
stop:    
	MOV AH,4CH
    INT 21H

;_________________________1______________________________
LEN PROC NEAR

   	lea dx,output		;给出输出提示
    mov ah,9
    int 21h
    
    enterline			;回车换行
    
    ;(有效数值为0~65535)  待转换数放置于AX寄存器中
    LEA si,INPUTSTR
    MOV AX,[SI+1]
    MOV AH,0
    mov bx,10000		;初始数位权值为10000
    
cov:xor dx,dx			;将dx:ax中的数值除以权值
	div bx
	mov cx,dx			;余数备份到CX寄存器中
	
	cmp flag,0			;检测是否曾遇到非0商值
	jne nor1			;如遇到过，则不管商是否为0都输出显示
	cmp ax,0			;如未遇到过，则检测商是否为0
	je cont				;为0则不输出显示
	
nor1:
	mov dl,al			;将商转换为ascii码输出显示
	add dl,30h
	mov ah,2
	int 21h
	
	mov flag,1			;曾遇到非0商，则将标志置1
	
cont:
	cmp bx,10			;检测权值是否已经修改到十位了
	je outer			;如果相等，则完成最后的个位数输出显示
	
	xor dx,dx			;将数位权值除以10
	mov ax,bx
	mov bx,10
    div bx
    mov bx,ax
    
    mov ax,cx			;将备份的余数送入AX
    jmp cov    			;继续循环
   
outer:
	mov dl,cl			;最后的个位数变为ascii码输出显示
	add dl,30h
	mov ah,2
	int 21h   
	enterline

	RET
LEN ENDP
;________________________2_______________________________
REV PROC NEAR

MOV CX,0
LEA SI,INPUTSTR
R1:
	MOV AL,[SI+2]
	CMP AL,36
	JE R2
	MOV AH,0
	PUSH AX
	INC CX
	INC SI
	JMP R1
R2:
	POP DX
	MOV DH,0
	MOV AH,02H
	INT 21H
	LOOP R2
RET
REV ENDP
;____________________________3___________________________
JUDGE PROC NEAR
	MOV SI,0
	MOV CX,0
	LEA si,INPUTSTR

	MOV CX,[SI+1] 
	MOV CH,0
LOP:MOV BX,[SI+2] 
	MOV BH,0 

	MOV AL,BL
	CMP AL,'a'      
	JB B1          ;小于a
	CMP AL,'z'  
	JA B3          ;大于z
	INC NUM  
	JMP B3
B1:
	CMP AL,'A' 
	JB B3          ;小于A
	CMP AL,'Z'
	JA B3          ;大于Z
	INC NUM    
	JMP B3

B3:
	INC SI         ;取下一个字符
	LOOP LOP       ;循环
	
	ENTERLINE
	MOV BX,0
	LEA SI,INPUTSTR
	MOV AL,[SI+1]
	SUB AL,NUM
    MOV AH,0
    mov bx,10000		;初始数位权值为10000
    
B4:xor dx,dx			;将dx:ax中的数值除以权值
	div bx
	mov cx,dx			;余数备份到CX寄存器中
	
	cmp flag1,0			;检测是否曾遇到非0商值
	jne B5			;如遇到过，则不管商是否为0都输出显示
	cmp ax,0			;如未遇到过，则检测商是否为0
	je B6				;为0则不输出显示
	
B5:
	mov dl,al			;将商转换为ascii码输出显示
	add dl,30h
	mov ah,2
	int 21h
	
	mov flag1,1			;曾遇到非0商，则将标志置1
	
B6:
	cmp bx,10			;检测权值是否已经修改到十位了
	je B7			;如果相等，则完成最后的个位数输出显示
	
	xor dx,dx			;将数位权值除以10
	mov ax,bx
	mov bx,10
    div bx
    mov bx,ax
    
    mov ax,cx			;将备份的余数送入AX
    jmp B4    			;继续循环
   
B7:
	mov dl,cl			;最后的个位数变为ascii码输出显示
	add dl,30h
	mov ah,2
	int 21h   
	enterline
    
    RET
JUDGE ENDP
;________________________4_______________________________
BIGASC PROC NEAR
	MOV SI,0
	LEA SI,INPUTSTR
	MOV CX,[SI+1]
	MOV BX,0
	MOV AX,0
A0:	MOV AL,[SI+2]
	CMP AL,'$'
	JE A2
	CMP AL,BL
	JG A1
	JMP A3
A1:	MOV BL,AL
A3:	INC SI
	JMP A0
A2:	
	LEA dx,STRING2  ;提示
    mov ah,09h
    int 21h
    
	MOV DL,BL
	MOV AH,02h
	INT 21H
	ENTERLINE
RET
BIGASC ENDP
;_________________________5______________________________
INT1 PROC NEAR
	
beginint:
	lea dx,input    ;给出输入提示
    mov ah,9
    int 21h
    
    
    lea dx,numin		;从键盘接收输入数值放入numin缓冲区
    mov ah,0AH
    int 21h
    
    enterline		;回车换行
    
    mov cl,numin+1	;获取实际键入字符数，置于CX寄存器中
    xor ch,ch
    
    xor di,di		;累加器清0
    
    xor dx,dx		;DX寄存器清0
    
    mov bx,1		;由于从个位数开始算起，因而将所乘权值设为1
    
    lea si,numin+2	;将si指向接收到的第1个字符位置
    add si,cx		;因为从个位算起，所以将si指向最后1个接收到的个位数
    dec si
    
covid:mov al,[si]		;取出个位数给al
	cmp al,'0'		;边界检查：如果输入不是0-9的数字，就报错
	jb e
	cmp al,'9'
	ja e

    sub al,30h		;将al中的ascii码转为数字
    xor ah,ah
    mul bx			;乘以所处数位的权值
    cmp dx,0		;判断结果是否超出16位数范围，如超出则报错
    jne e
    
    add di,ax		;将形成的数值放在累加器di中
    jc e		;如数值超过16位数范围报错
    
        
    mov ax,bx		;将BX中的数位权值乘以10
    mov bx,10
    mul bx
    mov bx,ax
    
    dec si			;si指针减1，指向前一数位
    loop covid    	;按CX中的字符个数计数循环
    add di,1
    
    
    mov cx,di
    		;将最终转换结果从di存放到cx
PRINT:
mov ax,0
mov bx,0
mov si,0
LEA SI,INPUTSTR
I1:
	MOV AL,[SI+2]
	CMP AL,'$'
	JE i2
	MOV AH,0
	PUSH AX
	INC SI
	JMP I1
I2:
	POP DX
	MOV DH,0
	MOV AH,02H;出栈
	INT 21H
	LOOP I2
	
	
	
I0:	MOV AX,[SI+1]
	SUB AX,di
	MOV CX,AX
	POP BX
	LOOP I0
	JMP NORMAL
	
	
E:MOV DX,OFFSET ERROR
	MOV AH,09H
	INT 21H
	  jmp beginint 		;如出错则返回起始点重新输入  
	  enterline
NORMAL:
RET
INT1 ENDP
;_______________________________________________________

CODES ENDS
    END START








