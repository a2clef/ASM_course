.586
.MODEL flat, stdcall
.STACK 4096
option casemap : none;

INCLUDELIB msvcrt.lib

printf		PROTO C : dword, : vararg
scanf		PROTO C : dword, : vararg
gets		PROTO C : dword
_getche		PROTO C
ExitProcess	PROTO : DWORD
psum		PROTO : DWORD
exit		EQU <INVOKE ExitProcess, 0>


chr$ MACRO any_text : vararg
LOCAL textname


.data
textname db any_text, 0
ALIGN 4


.code
EXITM<OFFSET textname>
ENDM

incp	MACRO pp
	inc	pp
	.if pp <= 16
		jnz	incl
	.endif
	mov	pp, 0
incl:nop
	endm

.data
	buf	BYTE	16 dup(? )
	ip	DWORD	0
	op	DWORD	0
	n	DWORD	0
	chr	BYTE 	0

.code
main PROC
	invoke	printf, chr$("请输入数字或大写字母，或者'+','-',或者ESC退出", 0dh, 0ah)
start:
	invoke	_getche

	cmp	al, 1BH
	jz	over
	
	cmp al, '+'
	jnz npp
	push op
	push ip
	push offset buf
	call pq


	invoke 	printf, chr$(" 队首下标为：%d "), ip
	invoke 	printf, chr$( " 队尾下标为：%d "), op
	invoke	printf, chr$("元素个数为：%d",0DH,0AH),n

	jmp start

npp:
	cmp	al, '-'
	jnz	judge
	push offset chr
	push offset op
	push offset buf
	call oq
	cmp eax, 0
	jz start
	invoke 	printf, chr$(0dh, 0ah, " 提取的元素为：%c", 0dh, 0ah), chr

judge: 
	cmp al, '0'
	jl LL1
	cmp al, '9'
	jg LL1
insert1:
	push eax
	push offset ip
	push offset buf
	call iq
	jmp LL0
LL1:
	cmp al, 'A'
	jl LL0
	cmp al, 'Z'
	jg LL0
insert2:
	push eax
	push offset ip
	push offset buf
	call iq
LL0:nop
	jmp	start

over:
	exit
main ENDP

;-----------------------------------------------------
iq PROC
	push ebp
	mov ebp, esp
	push esi
	push edi

	cmp	n, 16
	jz	full

	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add	esi, [edi]
	mov	eax, [ebp + 16]

	mov[esi], al

	incp DWORD ptr[edi]


	inc	n
	mov	eax, 1
	jmp 	oof
full :
	invoke	printf, chr$(0dh, 0ah, "队列已满", 0dh, 0ah)
	mov	eax, 0

oof :
	pop edi
	pop esi
	pop ebp
	ret
	iq ENDP
;---------------------------------------------------- -
oq PROC
	push ebp
	mov ebp, esp
	push esi
	push edi

	cmp	 n, 0
	jz	empty
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add esi, [edi]
	mov  	eax, [esi]
	mov   	esi, [ebp + 16]
	mov		[esi], al
	incp	DWORD ptr[edi]
	dec	n
	mov 	eax, 1
	jmp	emptyop
empty:
	invoke	printf, chr$(0dh, 0ah,"队列为空", 0dh, 0ah)
	mov  	eax, 0
emptyop:
	pop edi
	pop esi
	pop ebp
	ret
	oq ENDP

; ---------------------------------------------------- -
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

outpq:
	mov eax, [edi+esi]
	invoke	printf, chr$("%c"),AL
	incp esi
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
	pop ebp
	ret
	pq ENDP

END main
