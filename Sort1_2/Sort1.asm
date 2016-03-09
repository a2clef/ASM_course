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
count		dword	0
arr         sdword 100 dup(0)
.code
main	PROC
getcnt : invoke	printf, chr$("请输入要排序的数组元素个数: ")
		 invoke	scanf, chr$("%d"), offset count
		 invoke	getchar; 注意用scanf后一定要有这个调用，去掉键盘缓冲区的回车符。
		 CMP count, 1
		 JB getcnt

		 LEA ebx, arr
		 mov edi, 0
		 invoke	printf, chr$("请按顺序输入各个元素：")
	 getarr:invoke	scanf, chr$("%d"), ADDR[ebx]
			invoke	getchar
			add ebx, 4
			inc edi

			CMP edi, count
			JL getarr


			MOV ecx, count
			DEC ecx
		L1 : push ecx
			 lea ebx, arr
		 L2 : mov eax, [ebx]
			  cmp[ebx + 4], eax
			  JG L3
			  xchg eax, [ebx + 4]
			  mov[ebx], eax
		  L3 : add ebx, 4
			   loop L2
			   pop ecx
			   loop L1

			   invoke	printf, chr$("%d个数的排序：", 0dh, 0ah), count

			   lea ebx, arr
			   mov edi, 0
		   L4:  invoke	printf, chr$("%d "), dword ptr[ebx]
				add ebx, 4
				inc edi
				cmp edi, count
				JL L4

				invoke getchar

				main	ENDP

				END		main
