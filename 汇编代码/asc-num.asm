;ASCII������ת���ֵĳ���ֻ���������֣��������ֲ��ܳ���65535��
;ת��������ִ������ݶε�num�ֵ�Ԫ��
enterline macro		;����س����еĺ�ָ��
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
    buf db 10,?,10 dup(0)	;������̽����ַ���������������9���ַ�
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
   
    
begin:
    lea dx,input    ;����������ʾ
    mov ah,9
    int 21h
    
    
    lea dx,buf		;�Ӽ��̽���������ֵ����buf������
    mov ah,10
    int 21h
    
    enterline		;�س�����
    
    mov cl,buf+1	;��ȡʵ�ʼ����ַ���������CX�Ĵ�����
    xor ch,ch
    
    xor di,di		;�ۼ�����0
    
    xor dx,dx		;DX�Ĵ�����0
    
    mov bx,1		;���ڴӸ�λ����ʼ�������������Ȩֵ��Ϊ1
    
    lea si,buf+2	;��siָ����յ��ĵ�1���ַ�λ��
    add si,cx		;��Ϊ�Ӹ�λ�������Խ�siָ�����1�����յ��ĸ�λ��
    dec si
    
cov:mov al,[si]		;ȡ����λ����al
	cmp al,'0'		;�߽��飺������벻��0-9�����֣��ͱ���
	jb error
	cmp al,'9'
	ja error

    sub al,30h		;��al�е�ascii��תΪ����
    xor ah,ah
    mul bx			;����������λ��Ȩֵ
    cmp dx,0		;�жϽ���Ƿ񳬳�16λ����Χ���糬���򱨴�
    jne error
    
    add di,ax		;���γɵ���ֵ�����ۼ���di��
    jc error		;����ֵ����16λ����Χ����
    
        
    mov ax,bx		;��BX�е���λȨֵ����10
    mov bx,10
    mul bx
    mov bx,ax
    
    dec si			;siָ���1��ָ��ǰһ��λ
    loop cov    	;��CX�е��ַ���������ѭ��
   
    mov num,di		;������ת�������di��ŵ�num
   
   	
    lea dx,output	;����ת���ɹ�����ʾ
    mov ah,9
    int 21h
    enterline
    jmp stop

error:				;����������ʾ
	lea dx,err
    mov ah,9
    int 21h
    enterline 
    
    jmp begin 		;������򷵻���ʼ����������  
        
stop:
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START






