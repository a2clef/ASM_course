.586
.model flat, stdcall
.stack 4096
option casemap : none

includelib msvcrt.lib

printf	PROTO C : ptr byte, : vararg
scanf	PROTO C : ptr byte, : vararg
getchar PROTO C
_getch	PROTO C
_getche	PROTO C
ExitProcess   PROTO : dword
exit	EQU		<invoke	ExitProcess, 0>

chr$ MACRO any_text : vararg
LOCAL textname
.const
textname db any_text, 0
ALIGN 4
.code
EXITM <OFFSET textname>
ENDM

.data
ARR		sdword	100	dup(? )
n		dword ?


.code
main	proc
INVOKE	printf, chr$("����������Ԫ�صĸ���1~100:")
INVOKE	scanf, chr$("%d"), offset n
.if		n == 0
INVOKE	printf, chr$("������0��Ԫ�أ������˳�", 0dh, 0ah)
invoke	getchar
INVOKE	ExitProcess, 0
.elseif	n<0
INVOKE	printf, chr$("�Ƿ�����������˳�", 0dh, 0ah)
invoke	getchar
INVOKE	ExitProcess, 0
.endif

INVOKE	printf, chr$("�밴˳����������Ԫ��:")
mov		ecx, n
lea		ebx, ARR
mov		EDI, 0

L1:
push	ecx
INVOKE	scanf, chr$("%d"), ADDR ARR[edi * 4]
INVOKE	getchar
inc		EDI
pop		ecx
loop	L1
.if		n == 1
INVOKE	printf, chr$("����������Ϊ:", 0dh, 0ah)
INVOKE	printf, chr$("%d	"), sdword ptr ARR
invoke	getchar
INVOKE	ExitProcess, 0
.endif


mov		esi, 0
.REPEAT			; ʹ�þ���αָ��
	INC		esi
	; ------------------ -
	mov		EDI, 1
	.REPEAT
	mov		eax, ARR[EDI * 4 - 4]
	.if		ARR[EDI * 4]> eax
		inc		EDI
	.else
	xchg	eax, ARR[EDI * 4]
	mov		ARR[EDI * 4 - 4], eax
	inc		EDI
	.endif

	.UNTIL	edi>=n
.UNTIL esi >= n


	 INVOKE	printf, chr$("����������Ϊ:", 0dh, 0ah)
	 mov		ecx, n
	 lea		ebx, ARR
	 mov		EDI, 0


 L9:
push	ecx
INVOKE	printf, chr$("%d	"), ARR[EDI * 4]
inc		EDI
pop		ecx
loop	L9


invoke	getchar
INVOKE	ExitProcess, 0

main	endp
end		main
