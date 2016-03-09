.586
.MODEL flat, stdcall
.STACK 4096
option casemap : none;


printf		PROTO C : dword, : vararg
scanf		PROTO C : dword, : vararg
gets		PROTO C : dword
_getche		PROTO C
ExitProcess	PROTO : DWORD
exit		EQU <INVOKE ExitProcess, 0>

includelib msvcrt.lib


chr$ MACRO any_text : vararg
	LOCAL textname
.data
	textname db any_text, 0
	ALIGN 4
.code
	EXITM<OFFSET textname>
	ENDM

.data
	buf	BYTE	16 dup(?)
	ip	DWORD	0
	op	DWORD	0
	mp	DWORD	0
	n	DWORD	0
	chr	BYTE	0

.code
	
main	PROC
	invoke	printf, chr$("请输入数字或大写字母，或者'+','-',或者ESC退出", 0dh, 0ah)
start:	
	invoke	_getche; 
	cmp	al, 1BH
	jz	over

	cmp al, '+'
	jnz npp

	push op
	push ip
	push offset buf
	call pq
	add esp,12

	invoke 	printf, chr$(" 队首下标为：%d "), ip
	invoke 	printf, chr$("队尾下标为：%d "), op
	invoke	printf, chr$("元素个数为：%d",0DH,0AH),n

	jmp start

npp:
	cmp     al, '-'
	jnz	rule

	push offset chr
	push offset op
	push offset buf
	call oq
	add	 esp, 12

	.if eax != 0
		invoke	printf, chr$("出队元素：%c", 0dh, 0ah), chr
	.else
		invoke printf, chr$("队列已空", 0dh, 0ah)
	.endif
	jmp	start

rule:
	.if al >= 'A' && al <= 'Z' || al >= '0' && al <= '9' ;PROBLEM ? ? ? ? ?
	insert:
		push	eax
		push	offset ip
		push	offset buf
		call	iq
		add		esp, 12
		.if eax == 0
			invoke printf, chr$("队列已满", 0dh, 0ah)
		.endif
	.endif
	jmp	start
over:
	exit
main	ENDP


incp proc
	push ebp
	mov ebp,esp ;why no enter?

	push esi
	push edi

	mov edi, [ebp+8]
	inc dword ptr[edi]
	cmp dword ptr[edi],16
	jnz notend
	mov dword ptr[edi],0

notend:

	pop edi
	pop esi
	LEAVE
	ret
incp endp


iq	proc
	push ebp
	mov  ebp, esp
	push esi
	push edi
	mov	eax, 0 

	cmp n,16
	jz fulli
	
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add	esi, [edi]
	mov	al, [ebp + 16]
	mov[esi], AL

	push edi
	call incp
	ADD esp,4


	inc	n
	mov	eax, 1 
fulli: 
	pop edi
	pop esi
	leave
	ret
iq	endp

oq	proc
	push ebp
	mov  ebp, esp
	push esi
	push edi
	mov	eax, 0
	cmp n,0
	jz emptyo
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add	esi, [edi]
	mov	al, [esi]
	mov	esi, [ebp + 16]
	mov[esi], al


	push edi
	call incp
	ADD esp,4

	dec	n
	mov	eax, 1
emptyo:
	pop edi
	pop esi
	leave
	ret
oq	endp


pq PROC
	push	ebp
	mov		ebp,	esp

	push	esi
	push	edi

	cmp n,0
	jz	emptypq

	invoke	printf, chr$(0dh,0ah)

	mov edi, [ebp+8]
	mov esi, [ebp+16]
	mov mp,esi
outpq:
	mov eax, [edi+esi]
	invoke	printf, chr$("%c"),AL

	push offset mp
	call incp
	add esp,4
	mov esi,mp
	
	cmp esi, [ebp+12]
	jnz outpq
	jmp overpq

emptypq:
	invoke	printf, chr$(0dh, 0ah, "队列为空", 0dh, 0ah)
	mov	eax,0
overpq:
	mov eax,n
	pop edi
	pop esi
	LEAVE
	ret
	pq ENDP



END main
