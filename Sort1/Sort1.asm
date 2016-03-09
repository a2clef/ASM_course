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
ARR		sdword	100	dup(?)
n		dword	?


.code	
	main	proc
	INVOKE	printf, chr$("请输入数组元素的个数1~100:")
	INVOKE	scanf, chr$("%d"), offset n

	.if		n==0
		INVOKE	printf, chr$("输入了0个元素，程序退出",0dh,0ah)
		invoke	getchar
		INVOKE	ExitProcess, 0
	.elseif	n<0
		INVOKE	printf, chr$("非法输出，程序退出", 0dh, 0ah)
		invoke	getchar
		INVOKE	ExitProcess, 0
	.endif


	INVOKE	printf, chr$("请按顺序输入所有元素:")
	mov		ecx,	n
	lea		ebx,	ARR
	mov		EDI,	0

L1:	
	push	ecx
	INVOKE	scanf, chr$("%d"), ADDR[ebx+EDI*4]
	INVOKE	getchar
	inc		EDI
	pop		ecx
	loop	L1

	.if		n == 1
	INVOKE	printf, chr$("数组排序结果为:", 0dh, 0ah)
	INVOKE	printf, chr$("%d	"), sdword ptr ARR
	invoke	getchar
	INVOKE	ExitProcess, 0
	.endif


	mov		ecx,	n
	dec		ecx

L2:	push	ecx
	mov		EDI,	0

L3:	
	mov		eax, [EBX + EDI * 4 + 4]
	cmp		[EBX + EDI * 4], eax
	jl		L4
	xchg	eax, [EBX + EDI * 4]
	mov		[EBX + EDI * 4 + 4],eax
L4:	inc		EDI
	loop	L3
	pop		ecx
	loop L2
	

	INVOKE	printf, chr$("数组排序结果为:", 0dh, 0ah)
	mov		ecx, n
	lea		ebx, ARR
	mov		EDI, 0
	

L9:
	push	ecx
	INVOKE	printf, chr$("%d	"), sdword ptr [EBX + EDI * 4]
	inc		EDI
	pop		ecx
	loop	L9


	invoke	getchar
	INVOKE	ExitProcess, 0
	main	endp
	end		main
