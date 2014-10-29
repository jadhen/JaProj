.686 
.387
.model flat, stdcall 
.xmm
.data
.code

dodaj proc uses ebx a:DWORD, b:DWORD
mov eax,a
mov ebx,b
add eax, ebx

ret	;wartoœæ zwracana jest przez akumulator!

dodaj endp 

end 