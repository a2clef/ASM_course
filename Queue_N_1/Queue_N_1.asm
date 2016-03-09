.386
.model flat, stdcall
option casemap : none
include windows.inc
include irvine32.inc
include LQueue.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
.data
pstFirst pstLQueue NULL
pstLast pstLQueue NULL
pstFreeList pstLQueue NULL
dwCount dword 0
.code
;////////////////////////////////////////////////////////////
; ���ڴ���һ���ڵ���ڴ�, ���ջ�еĽڵ��ڴ�, ��ô�ʹ�ջ�л�ȡ,
; ���ջ��û��, ����API��������ڴ�.
;////////////////////////////////////////////////////////////
CreateSpace proc uses ebx
mov eax, pstFreeList
or eax, eax; ���ջ��û�нڵ��ڴ�, ��ô
jne next
invoke GlobalAlloc, GPTR, sizeof LQueue
ret; ��API����һ���ڵ���ڴ�, Ȼ���eax�з���.
next:
mov ebx, eax
mov ebx, (LQueue ptr[ebx]).next
mov pstFreeList, ebx; �����ջ��ȡ��һ���ڵ��ڴ沢����.
ret
CreateSpace endp
;////////////////////////////////////////////////////////////
; ����ɾ��һ���ڵ���ڴ�, ʵ������ֻ�ǰѸýڵ����ջ��, ����һ��
; ����������Ҫ����һ���ڵ�������ڴ�ʱ�ͻ��ܶ�.
;////////////////////////////////////////////////////////////
FreeSpace proc uses ebx pstQueue : ptr LQueue
mov ebx, pstQueue
push pstFreeList
pop(LQueue ptr[ebx]).next
mov pstFreeList, ebx; ��Ҫɾ���Ľڵ���ջ����, �γ�ջ�е�һ���ڵ�.
ret
FreeSpace endp
;////////////////////////////////////////////////////////////
; ɾ����ʽ�����е����нڵ���ڴ�, ������������Ա����´���һ��
; �ڵ�.
;////////////////////////////////////////////////////////////
Clear proc uses ebx
mov ebx, pstFirst
or ebx, ebx
je quit; ������б����Ϳ�, ��ô���˳��ù���.
.while ebx
mov pstLast, ebx
mov ebx, (LQueue ptr[ebx]).next
invoke FreeSpace, pstLast; �������, ��ô���ɾ��(����ջ��)���нڵ�.
.endw
mov pstFirst, NULL
mov pstLast, NULL
mov dwCount, 0
quit:
ret
Clear endp
;////////////////////////////////////////////////////////////
; ��ջ�е����нڵ��ͷ�, ��ɾ��ջ���ݽṹ.�������ڳ���������ͷ�
; ���а��������еĽڵ���ڴ�Ĺ���.
;////////////////////////////////////////////////////////////
FreeMemory proc uses ebx esi
call Clear; ������ж����еĽڵ㵽ջ��.
mov ebx, pstFreeList
or ebx, ebx
je quit; ���ջ�Լ������ж�û�нڵ�, ��ô�˳��ù���.
.while ebx
mov esi, ebx
mov ebx, (LQueue ptr[ebx]).next
push ebx
invoke GlobalFree, esi; ���ɾ��ջ�е����нڵ�.
pop ebx
.endw
quit :
ret
FreeMemory endp
;////////////////////////////////////////////////////////////
; �ڶ����в���һ���ڵ�.����ýڵ�Ϊ��һ���ڵ�, ��ôӦ��ʹpstFirst
; ҲҪָ����.��������ڵ�Ӧ�ò��뵽pstLast��ָ��Ľڵ�֮��, ����Ҫ
; �޸�pstLastָ��, ʹ֮����ʼ��ָ�����һ���ڵ�.
;////////////////////////////////////////////////////////////
AddValue proc uses esi dwVal : dword
call CreateSpace
or eax, eax
je quit; �����ڴ�ռ�Ĺ��̷���NULL, ˵��û�����뵽�ڴ�.
push dwVal
pop(LQueue ptr[eax]).value; �Ըýڵ����ֵ��ֵ.
mov(LQueue ptr[eax]).next, NULL; �Ըýڵ��ָ����ֵ.
.if pstFirst == NULL; ���ԭ������Ϊ��, ��ô�����Ľڵ��ǵ�һ���ڵ�, ��ʱ����ָ�붼ָ����.
mov pstFirst, eax
mov pstLast, eax
.else
mov esi, pstLast
mov(LQueue ptr[esi]).next, eax; ���´����Ľڵ����pstLast��ָ��Ľڵ�֮��.
mov pstLast, eax; ʹpstLast����ָ���´����Ľڵ�.
.endif
inc dwCount; �ڵ�����һ.
or eax, 1; ����true.
quit:; ����ڵ�ռ䴴��ʧ��, ��ô����false.
	 ret
	 AddValue endp
	 ;////////////////////////////////////////////////////////////
; �ڶ�����ɾ��һ���ڵ�, ���Ҫɾ���Ľڵ�Ϊ���Ľڵ�, ��ô����ͬ
; �಻��Ҫ�޸�pstFirstָ��, ����Ҫ�޸�pstLastָ��.����������
; ��, ��ôֻҪ�޸�pstFirst, ʹ��ָ����һ���ڵ�, ���Ƴ��Ľڵ����
; ջ�о�OK��.��Ȼ���ɾ���ڵ�ɹ�, ��ô���ǽ���dwCount��һ����.
;////////////////////////////////////////////////////////////
DelValue proc uses esi pdwVal : ptr dword
mov eax, pstFirst
or eax, eax
je quit; �������Ϊ��, ��ô����false
mov esi, pdwVal
push(LQueue ptr[eax]).value
pop dword ptr[esi]; ����Ҫɾ���ڵ��ֵ.
mov esi, eax
mov eax, (LQueue ptr[eax]).next; ʹeaxָ����һ���ڵ�.
invoke FreeSpace, esi; ɾ��֮ǰһ���ڵ�.
or eax, eax
jne next
mov pstLast, eax; ���ɾ���������Ľڵ�, ��ô�޸�pstLastָ��.
next:
mov pstFirst, eax; ʹpstFirstָ����һ�ڵ�.
dec dwCount; �����еĽڵ�����һ.
or eax, 1; ����true.
quit:
ret
DelValue endp
;////////////////////////////////////////////////////////////
; ������һ���ڵ����ֵ��.
;////////////////////////////////////////////////////////////
GetValue proc uses esi pdwVal : ptr dword
mov eax, pstFirst
or eax, eax
je quit; �������Ϊ��, ��ô����false
mov esi, pdwVal
push(LQueue ptr[eax]).value
pop dword ptr[esi]; ����pstFirst��ָ��Ľڵ�ֵ.
or eax, 1; ����true.
quit:
ret
GetValue endp
;////////////////////////////////////////////////////////////
; ���ض����еĽڵ���.
;////////////////////////////////////////////////////////////
QueueLength proc
mov eax, dwCount
ret
QueueLength endp
;////////////////////////////////////////////////////////////
; �Զ��еĲ��Գ���.
;////////////////////////////////////////////////////////////
main proc
local dwTemp : dword
call Clear; ��������е����нڵ�.
invoke AddValue, 1
invoke AddValue, 2
invoke AddValue, 3; ��������ڵ�.
call QueueLength
mov ecx, eax
temp1 :
push ecx
invoke DelValue, addr dwTemp
mov eax, dwTemp
call WriteDec
mov al, ' '
call WriteChar
pop ecx
loop temp1
call Crlf
call Clear; �ٴ���������е����нڵ�, �Ա��ؽ�.
invoke AddValue, 1
invoke AddValue, 2
invoke AddValue, 3
invoke AddValue, 4; ������ĸ��ڵ�.
call QueueLength
mov ecx, eax
temp2 :
push ecx
invoke GetValue, addr dwTemp
mov eax, dwTemp
call WriteDec
mov al, ' '
call WriteChar
invoke DelValue, addr dwTemp
mov eax, dwTemp
call WriteDec
mov al, ' '
call WriteChar
pop ecx
loop temp2
call Crlf
call FreeMemory
invoke ExitProcess, NULL
main endp
end main