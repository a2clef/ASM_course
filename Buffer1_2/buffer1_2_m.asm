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


incp	macro pp
	local	incl
	inc	pp
	cmp	pp, 16
	jnz	incl
	mov	pp, 0
incl:nop
	ENDM

.data
	buf	BYTE	16 dup(?)
	ip	DWORD	0
	op	DWORD	0
	n	DWORD	0
	chr	BYTE	0

.code
	
main	PROC
	invoke	printf, chr$("���������ֻ��д��ĸ������'+','-',����ESC�˳�", 0dh, 0ah)
start:	
	invoke	_getche; ע����scanf��һ��Ҫ��������ã�ȥ�����̻������Ļس�����
	cmp	al, 1BH
	jz	over
	cmp     al, '-'
	jnz	rule

	push offset chr
	push offset op
	push offset buf
	call oq
	add	 esp, 12

	.if eax != 0
		invoke	printf, chr$("��ȡ��Ԫ��Ϊ��%c", 0dh, 0ah), chr
	.else
		invoke printf, chr$("EMPTY!", 0dh, 0ah)
	.endif
	jmp	start

rule:
	.if al >= 'A' && al <= 'Z' || al >= '0' && al <= '9'
	insert:
		push	eax
		push	offset ip
		push	offset buf
		call	iq; invoke	iq, offset buf, offset ip, al
		add		esp, 12
		.if eax == 0
			invoke printf, chr$("FULL!", 0dh, 0ah)
		.endif
	.endif
	jmp	start
over:
	exit
main	ENDP

iq	proc
	push ebp
	mov  ebp, esp
	push esi
	push edi
	mov	eax, 0; ������0��Ԫ��
	.if n == 16
		jmp iqover
	.endif
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add	esi, [edi]
	mov	al, [ebp + 16]
	mov[esi], al
	incp	DWORD PTR[edi]
	inc	n
	mov	eax, 1; ������һ��Ԫ��
iqover : 
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
	mov	eax, 0; ��ȡ��0��Ԫ��
	.if n == 0
		jmp oqover
	.endif
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	add	esi, [edi]
	mov	al, [esi]
	mov	esi, [ebp + 16]
	mov[esi], al
	incp	DWORD PTR[edi]
	dec	n
	mov	eax, 1; ��ȡ��1��Ԫ��
oqover:
	pop edi
	pop esi
	leave
	ret
oq	endp

END main