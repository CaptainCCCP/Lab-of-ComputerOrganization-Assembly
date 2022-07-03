enterline macro		;����س����еĺ�ָ��
	mov dl,13
	mov ah,2
	int 21h
	mov dl,10
	mov ah,2
	int 21h
endm
;_______________________________________________________
DATAS SEGMENT
    ;�˴��������ݶδ���  
STRING0 db "please input a string:$"
STRING2 DB "THE BIGGEST ASCII IS:$"
INPUTSTR DB 50,?,50 dup('$')
;�������ַ�����;ʵ�ʽ��ܵ��ַ�����;�ַ���������
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
    ;�˴������ջ�δ���
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
    ;�˴��������δ���
    LEA dx,STRING0  ;��ʾ
    mov ah,09h
    int 21h
    enterline
    ;=========
    mov ah,0ah  ;�����ַ���
    lea dx,INPUTSTR
    int 21h
    ;=========
    XOR AX,AX
	XOR BX,BX
    MOV BX,40        ;�߽��ж�
    
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
    CALL LEN;����1
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL REV;����2
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL JUDGE;����ĸ3
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL BIGASC;���asc4
    ;=========
    XOR CX,CX
    XOR AX,AX
    XOR DX,DX
    CALL INT1;ָ�����5
;_______________________________________________________
JMP STOP
ERR:
	enterline
	MOV DX,OFFSET ERROR;����
	MOV AH,09H
	INT 21H
stop:    
	MOV AH,4CH
    INT 21H

;_________________________1______________________________
LEN PROC NEAR

   	lea dx,output		;���������ʾ
    mov ah,9
    int 21h
    
    enterline			;�س�����
    
    ;(��Ч��ֵΪ0~65535)  ��ת����������AX�Ĵ�����
    LEA si,INPUTSTR
    MOV AX,[SI+1]
    MOV AH,0
    mov bx,10000		;��ʼ��λȨֵΪ10000
    
cov:xor dx,dx			;��dx:ax�е���ֵ����Ȩֵ
	div bx
	mov cx,dx			;�������ݵ�CX�Ĵ�����
	
	cmp flag,0			;����Ƿ���������0��ֵ
	jne nor1			;�����������򲻹����Ƿ�Ϊ0�������ʾ
	cmp ax,0			;��δ���������������Ƿ�Ϊ0
	je cont				;Ϊ0�������ʾ
	
nor1:
	mov dl,al			;����ת��Ϊascii�������ʾ
	add dl,30h
	mov ah,2
	int 21h
	
	mov flag,1			;��������0�̣��򽫱�־��1
	
cont:
	cmp bx,10			;���Ȩֵ�Ƿ��Ѿ��޸ĵ�ʮλ��
	je outer			;�����ȣ���������ĸ�λ�������ʾ
	
	xor dx,dx			;����λȨֵ����10
	mov ax,bx
	mov bx,10
    div bx
    mov bx,ax
    
    mov ax,cx			;�����ݵ���������AX
    jmp cov    			;����ѭ��
   
outer:
	mov dl,cl			;���ĸ�λ����Ϊascii�������ʾ
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
	JB B1          ;С��a
	CMP AL,'z'  
	JA B3          ;����z
	INC NUM  
	JMP B3
B1:
	CMP AL,'A' 
	JB B3          ;С��A
	CMP AL,'Z'
	JA B3          ;����Z
	INC NUM    
	JMP B3

B3:
	INC SI         ;ȡ��һ���ַ�
	LOOP LOP       ;ѭ��
	
	ENTERLINE
	MOV BX,0
	LEA SI,INPUTSTR
	MOV AL,[SI+1]
	SUB AL,NUM
    MOV AH,0
    mov bx,10000		;��ʼ��λȨֵΪ10000
    
B4:xor dx,dx			;��dx:ax�е���ֵ����Ȩֵ
	div bx
	mov cx,dx			;�������ݵ�CX�Ĵ�����
	
	cmp flag1,0			;����Ƿ���������0��ֵ
	jne B5			;�����������򲻹����Ƿ�Ϊ0�������ʾ
	cmp ax,0			;��δ���������������Ƿ�Ϊ0
	je B6				;Ϊ0�������ʾ
	
B5:
	mov dl,al			;����ת��Ϊascii�������ʾ
	add dl,30h
	mov ah,2
	int 21h
	
	mov flag1,1			;��������0�̣��򽫱�־��1
	
B6:
	cmp bx,10			;���Ȩֵ�Ƿ��Ѿ��޸ĵ�ʮλ��
	je B7			;�����ȣ���������ĸ�λ�������ʾ
	
	xor dx,dx			;����λȨֵ����10
	mov ax,bx
	mov bx,10
    div bx
    mov bx,ax
    
    mov ax,cx			;�����ݵ���������AX
    jmp B4    			;����ѭ��
   
B7:
	mov dl,cl			;���ĸ�λ����Ϊascii�������ʾ
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
	LEA dx,STRING2  ;��ʾ
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
	lea dx,input    ;����������ʾ
    mov ah,9
    int 21h
    
    
    lea dx,numin		;�Ӽ��̽���������ֵ����numin������
    mov ah,0AH
    int 21h
    
    enterline		;�س�����
    
    mov cl,numin+1	;��ȡʵ�ʼ����ַ���������CX�Ĵ�����
    xor ch,ch
    
    xor di,di		;�ۼ�����0
    
    xor dx,dx		;DX�Ĵ�����0
    
    mov bx,1		;���ڴӸ�λ����ʼ�������������Ȩֵ��Ϊ1
    
    lea si,numin+2	;��siָ����յ��ĵ�1���ַ�λ��
    add si,cx		;��Ϊ�Ӹ�λ�������Խ�siָ�����1�����յ��ĸ�λ��
    dec si
    
covid:mov al,[si]		;ȡ����λ����al
	cmp al,'0'		;�߽��飺������벻��0-9�����֣��ͱ���
	jb e
	cmp al,'9'
	ja e

    sub al,30h		;��al�е�ascii��תΪ����
    xor ah,ah
    mul bx			;����������λ��Ȩֵ
    cmp dx,0		;�жϽ���Ƿ񳬳�16λ����Χ���糬���򱨴�
    jne e
    
    add di,ax		;���γɵ���ֵ�����ۼ���di��
    jc e		;����ֵ����16λ����Χ����
    
        
    mov ax,bx		;��BX�е���λȨֵ����10
    mov bx,10
    mul bx
    mov bx,ax
    
    dec si			;siָ���1��ָ��ǰһ��λ
    loop covid    	;��CX�е��ַ���������ѭ��
    add di,1
    
    
    mov cx,di
    		;������ת�������di��ŵ�cx
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
	MOV AH,02H;��ջ
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
	  jmp beginint 		;������򷵻���ʼ����������  
	  enterline
NORMAL:
RET
INT1 ENDP
;_______________________________________________________

CODES ENDS
    END START








