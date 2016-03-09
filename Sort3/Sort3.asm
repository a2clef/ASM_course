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
	INVOKE	printf, chr$("请输入数组元素的个数1~100:")
	INVOKE	scanf, chr$("%d"), offset n
	.if		n == 0
	INVOKE	printf, chr$("输入了0个元素，程序退出", 0dh, 0ah)
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

L1:	push	ecx
	INVOKE	scanf, chr$("%d"), ADDR[ebx]
	INVOKE	getchar
	add		ebx,	4
	pop		ecx
	loop	L1
	.if		n == 1
	INVOKE	printf, chr$("数组排序结果为:", 0dh, 0ah)
	INVOKE	printf, chr$("%d	"), sdword ptr ARR
	invoke	getchar
	INVOKE	ExitProcess, 0
	.endif


	MOV		ecx,	n
	DEC		ecx
L2:	push	ecx
	lea		ebx,	ARR
L3:	mov		eax,	[ebx]
	cmp		[ebx + 4], eax
	JG		L4
	xchg	eax,	[ebx + 4]
	mov		[ebx],	eax
L4:	add		ebx,	4
	loop	L3
	pop		ecx
	loop	L2



	INVOKE	printf, chr$("数组排序结果为:", 0dh, 0ah)

	lea		ebx,	ARR
	mov		edi,	0
L9:	invoke	printf, chr$("%d	"), dword ptr[ebx]
	add		ebx,	4
	inc		edi
	cmp		edi,	n
	JL		L9

	invoke	getchar

	INVOKE	ExitProcess, 0
main	endp
end		main
