;ASCII码输入转数字的程序，只能输入数字，并且数字不能超过65535，
;转换完的数字存在数据段的num字单元中
enterline macro		;定义回车换行的宏指令
	mov dl,13
	mov ah,2
	int 21h
	mov dl,10
	mov ah,2
	int 21h
endm


DATAS SEGMENT
    num dw ?
    input db 'Please Input Number(<=65535):$'
    output db 'Convertion Success!$' 
    err db 'Illegal input! Please Try Again$'
    buf db 10,?,10 dup(0)	;定义键盘接收字符缓冲区，最多接收9个字符
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
   
    
begin:
    lea dx,input    ;给出输入提示
    mov ah,9
    int 21h
    
    
    lea dx,buf		;从键盘接收输入数值放入buf缓冲区
    mov ah,10
    int 21h
    
    enterline		;回车换行
    
    mov cl,buf+1	;获取实际键入字符数，置于CX寄存器中
    xor ch,ch
    
    xor di,di		;累加器清0
    
    xor dx,dx		;DX寄存器清0
    
    mov bx,1		;由于从个位数开始算起，因而将所乘权值设为1
    
    lea si,buf+2	;将si指向接收到的第1个字符位置
    add si,cx		;因为从个位算起，所以将si指向最后1个接收到的个位数
    dec si
    
cov:mov al,[si]		;取出个位数给al
	cmp al,'0'		;边界检查：如果输入不是0-9的数字，就报错
	jb error
	cmp al,'9'
	ja error

    sub al,30h		;将al中的ascii码转为数字
    xor ah,ah
    mul bx			;乘以所处数位的权值
    cmp dx,0		;判断结果是否超出16位数范围，如超出则报错
    jne error
    
    add di,ax		;将形成的数值放在累加器di中
    jc error		;如数值超过16位数范围报错
    
        
    mov ax,bx		;将BX中的数位权值乘以10
    mov bx,10
    mul bx
    mov bx,ax
    
    dec si			;si指针减1，指向前一数位
    loop cov    	;按CX中的字符个数计数循环
   
    mov num,di		;将最终转换结果从di存放到num
   
   	
    lea dx,output	;给出转换成功的提示
    mov ah,9
    int 21h
    enterline
    jmp stop

error:				;给出错误提示
	lea dx,err
    mov ah,9
    int 21h
    enterline 
    
    jmp begin 		;如出错则返回起始点重新输入  
        
stop:
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START






