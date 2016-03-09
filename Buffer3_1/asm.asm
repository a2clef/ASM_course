.586
.model flat, c
.stack 4096
option casemap : none;

public c bufdasm, n, iq, oq, pq

extern c chr : byte, ip : dword, op : dword


incp			proto c, p : ptr dword
printf			proto c : dword, : vararg
iq				proto, bufd : ptr dword, ipd : ptr dword, chv : byte
oq				proto, bufd : ptr dword, opd : ptr dword, chd : ptr dword
pq				proto, bufd : ptr dword, ipv : dword, opv : dword


chr$ macro any_text : vararg
	local textname
.const
	textname db any_text, 0
	align 4
.code
	exitm <offset textname>
	endm

.data
	bufdasm	dword offset buf;
	buf	byte  16 dup(? );
	n   dword 0
	mp	dword 0
.code

iq proc, bufd:ptr dword, ipd : ptr dword, chv : byte
	cmp n, 16
	jz iqfull
	mov esi, bufd
	mov edi, ipd
	mov edx, [edi]
	add esi, edx
	mov al, chv

	mov byte ptr[esi], al
	inc n
	invoke incp, edi

	mov eax, 1
	jmp IQNORM
iqfull:
	invoke printf, chr$("队列已满", 0dh, 0ah)
	mov eax, 0
IQNORM:
	ret
	iq endp

oq proc, bufd : ptr dword, opd : ptr dword, chd : ptr dword
	cmp n, 0
	jz oqempty
	mov esi, bufd
	mov edi, opd
	mov ebx, [edi]
	add esi, ebx
	mov al, byte ptr[esi]
	mov edx, chd
	mov byte ptr[edx], al

	dec n
	push ebx
	invoke incp, edi
	mov eax, 1
	jmp oqnorm
oqempty:
	invoke printf, chr$("队列为空", 0dh, 0ah)
	mov eax, 0
oqnorm:
	ret
	oq endp

pq proc, bufd : ptr dword, ipv : dword, opv : dword
	cmp n,0
	jz	emptypq
	invoke	printf, chr$(0dh,0ah)
	mov edi, bufd
	mov esi, opv
	mov mp,esi
outpq:
	mov eax, [EDI+ESI]
	invoke	printf, chr$("%c"),AL
	invoke incp,offset mp
	mov esi,mp
	cmp esi, ipv
	jnz outpq
	jmp overpq
emptypq:
	invoke	printf, chr$(0dh, 0ah, "队列为空", 0dh, 0ah)
	mov	eax,0
overpq:
	mov eax,n
	ret
	pq endp

	end