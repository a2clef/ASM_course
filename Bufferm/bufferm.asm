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

incp	MACRO pp
	local incl
	inc	pp
	.if pp <= 16
		jnz	incl
	.endif
	mov	pp, 0
incl:nop
	endm




iq	MACRO bufd,ipd
	local fulli, overi
	push esi
	push edi
	cmp n,16
	jz fulli
	mov	esi, bufd
	mov	edi, ipd
	add	esi, [edi]
	mov[esi], AL
	incp DWORD PTR[edi]
	inc	n
	mov	eax, 1 
	jmp overi
fulli: 
	mov eax, 0
overi:
	pop esi
	pop edi
endm



oq	MACRO bufd, opd, chd
	PUSH EDI
	PUSH ESI
	mov	eax, 0
	cmp n,0
	jz emptyo
	mov	esi, bufd
	mov	edi, opd
	add	esi, [edi]
	mov	al, [esi]
	mov	esi, chd
	mov[esi], al


	incp DWORD PTR[edi]

	dec	n
	mov	eax, 1
emptyo:
	POP ESI
	POP EDI
ENDM


pq MACRO bufd, ipv, opv
	local outpq, emptypq, overpq
	PUSH ESI
	PUSH EDI
	cmp n,0
	jz	emptypq
	invoke	printf, chr$(0dh,0ah)
	mov edi, bufd
	mov esi, opv
	mov mp,esi
outpq:
	mov eax, [EDI+ESI]
	invoke	printf, chr$("%c"),AL
	incp mp
	mov esi,mp
	cmp esi, ipv
	jnz outpq
	jmp overpq
emptypq:
	invoke	printf, chr$(0dh, 0ah, "队列为空", 0dh, 0ah)
	mov	eax,0
overpq:
	mov eax,n
	POP EDI
	POP ESI
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

	pq offset buf,ip,op

	invoke 	printf, chr$(" 队首下标为：%d "), ip
	invoke 	printf, chr$("队尾下标为：%d "), op
	invoke	printf, chr$("元素个数为：%d",0DH,0AH),n

	jmp start

npp:
	cmp     al, '-'
	jnz	rule

	oq offset buf,offset op,offset chr

	.if eax != 0
		invoke	printf, chr$("出队元素：%c", 0dh, 0ah), chr
	.else
		invoke printf, chr$("队列已空", 0dh, 0ah)
	.endif
	jmp	start

rule:
	.if al >= 'A' && al <= 'Z' || al >= '0' && al <= '9' 
	insert:
		iq  offset buf, offset ip

		.if eax == 0
			invoke printf, chr$("队列已满", 0dh, 0ah)
		.endif
	.endif
	jmp	start
over:
	exit
main	ENDP





END main
