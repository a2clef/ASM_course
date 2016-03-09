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
; 用于创建一个节点的内存, 如果栈中的节点内存, 那么就从栈中获取,
; 如果栈中没有, 就用API函数获得内存.
;////////////////////////////////////////////////////////////
CreateSpace proc uses ebx
mov eax, pstFreeList
or eax, eax; 如果栈中没有节点内存, 那么
jne next
invoke GlobalAlloc, GPTR, sizeof LQueue
ret; 用API创建一个节点的内存, 然后从eax中返回.
next:
mov ebx, eax
mov ebx, (LQueue ptr[ebx]).next
mov pstFreeList, ebx; 否则从栈中取出一个节点内存并返回.
ret
CreateSpace endp
;////////////////////////////////////////////////////////////
; 用于删除一个节点的内存, 实际上它只是把该节点放入栈中, 这样一来
; 当我们再需要创建一个节点而申请内存时就会快很多.
;////////////////////////////////////////////////////////////
FreeSpace proc uses ebx pstQueue : ptr LQueue
mov ebx, pstQueue
push pstFreeList
pop(LQueue ptr[ebx]).next
mov pstFreeList, ebx; 把要删除的节点与栈相连, 形成栈中的一个节点.
ret
FreeSpace endp
;////////////////////////////////////////////////////////////
; 删除链式队列中的所有节点的内存, 用于清除队列以便重新创建一个
; 节点.
;////////////////////////////////////////////////////////////
Clear proc uses ebx
mov ebx, pstFirst
or ebx, ebx
je quit; 如果队列本来就空, 那么就退出该过程.
.while ebx
mov pstLast, ebx
mov ebx, (LQueue ptr[ebx]).next
invoke FreeSpace, pstLast; 如果不空, 那么逐个删除(存入栈中)所有节点.
.endw
mov pstFirst, NULL
mov pstLast, NULL
mov dwCount, 0
quit:
ret
Clear endp
;////////////////////////////////////////////////////////////
; 把栈中的所有节点释放, 即删除栈数据结构.这是用于程序结束而释放
; 所有包括队列中的节点的内存的过程.
;////////////////////////////////////////////////////////////
FreeMemory proc uses ebx esi
call Clear; 清除所有队列中的节点到栈中.
mov ebx, pstFreeList
or ebx, ebx
je quit; 如果栈以及队列中都没有节点, 那么退出该过程.
.while ebx
mov esi, ebx
mov ebx, (LQueue ptr[ebx]).next
push ebx
invoke GlobalFree, esi; 逐个删除栈中的所有节点.
pop ebx
.endw
quit :
ret
FreeMemory endp
;////////////////////////////////////////////////////////////
; 在队列中插入一个节点.如果该节点为第一个节点, 那么应该使pstFirst
; 也要指向它.否则这个节点应该插入到pstLast所指向的节点之后, 而且要
; 修改pstLast指针, 使之让它始终指向最后一个节点.
;////////////////////////////////////////////////////////////
AddValue proc uses esi dwVal : dword
call CreateSpace
or eax, eax
je quit; 创建内存空间的过程返回NULL, 说明没有申请到内存.
push dwVal
pop(LQueue ptr[eax]).value; 对该节点的数值域赋值.
mov(LQueue ptr[eax]).next, NULL; 对该节点的指针域赋值.
.if pstFirst == NULL; 如果原来队列为空, 那么创建的节点是第一个节点, 此时两个指针都指向它.
mov pstFirst, eax
mov pstLast, eax
.else
mov esi, pstLast
mov(LQueue ptr[esi]).next, eax; 将新创建的节点放在pstLast所指向的节点之后.
mov pstLast, eax; 使pstLast重新指向新创建的节点.
.endif
inc dwCount; 节点数加一.
or eax, 1; 返回true.
quit:; 如果节点空间创建失败, 那么返回false.
	 ret
	 AddValue endp
	 ;////////////////////////////////////////////////////////////
; 在队列中删除一个节点, 如果要删除的节点为最后的节点, 那么我们同
; 相不仅要修改pstFirst指针, 而且要修改pstLast指针.而不是最后节
; 点, 那么只要修改pstFirst, 使它指向下一个节点, 而移出的节点存入
; 栈中就OK了.当然如果删除节点成功, 那么我们将对dwCount减一操作.
;////////////////////////////////////////////////////////////
DelValue proc uses esi pdwVal : ptr dword
mov eax, pstFirst
or eax, eax
je quit; 如果队列为空, 那么返回false
mov esi, pdwVal
push(LQueue ptr[eax]).value
pop dword ptr[esi]; 返回要删除节点的值.
mov esi, eax
mov eax, (LQueue ptr[eax]).next; 使eax指向下一个节点.
invoke FreeSpace, esi; 删除之前一个节点.
or eax, eax
jne next
mov pstLast, eax; 如果删除的是最后的节点, 那么修改pstLast指针.
next:
mov pstFirst, eax; 使pstFirst指向下一节点.
dec dwCount; 队列中的节点数减一.
or eax, 1; 返回true.
quit:
ret
DelValue endp
;////////////////////////////////////////////////////////////
; 返回下一个节点的数值域.
;////////////////////////////////////////////////////////////
GetValue proc uses esi pdwVal : ptr dword
mov eax, pstFirst
or eax, eax
je quit; 如果队列为空, 那么返回false
mov esi, pdwVal
push(LQueue ptr[eax]).value
pop dword ptr[esi]; 返回pstFirst所指向的节点值.
or eax, 1; 返回true.
quit:
ret
GetValue endp
;////////////////////////////////////////////////////////////
; 返回队列中的节点数.
;////////////////////////////////////////////////////////////
QueueLength proc
mov eax, dwCount
ret
QueueLength endp
;////////////////////////////////////////////////////////////
; 对队列的测试程序.
;////////////////////////////////////////////////////////////
main proc
local dwTemp : dword
call Clear; 清除队列中的所有节点.
invoke AddValue, 1
invoke AddValue, 2
invoke AddValue, 3; 添加三个节点.
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
call Clear; 再次清除队列中的所有节点, 以便重建.
invoke AddValue, 1
invoke AddValue, 2
invoke AddValue, 3
invoke AddValue, 4; 再添加四个节点.
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