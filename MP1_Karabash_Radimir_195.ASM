format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable
        strAuthor db 'Karabash Radimir BSE195-1', 10, 0
        strGetParam db 'Input parameter x: ', 0
        strError db 'Parameter must be in range of [-500;14]', 10 , 0
        strScan db '%d',0
        strIntro db 'This program allows you to calculate, using a power series with an accuracy of no worse than 0.05%, the value of the function 1/(e^x) for a given parameter x', 10, 0
        strParam db 'Parameter x equals %d', 10, 0
        strSer db 'Value of 1\exp(%d), that calculate with power series, equals %lf', 10, 0
        strCheck db 'Accurate value of 1/exp(%d) equals %lf', 0
        leftB        dd -500
        rightB       dd 14
        pow          dd 1
        x            dd ?
        tmp          dq ?
        delta        dq 0.00005
        checkValue   dq ?
        current      dq ?
        prev         dq ?
        myValue      dq ?
        e            dq 2.7182818284
        n            dd 1
        factor       dd 1

section '.code' code readable executable

;------------------------Print--------------------------------------------
;macro Print format, [args] {
macro Print [arg] {
  reverse
    push arg
  common
    call [printf]
}

;------------------------Scanner--------------------------------------------
macro Scan [args] {
  reverse
    push args
  common
    call [scanf]
}

;--------------------------Factorial----------------------------------------
macro Factorial len {
mov eax, [factor]
imul eax,[len]
mov [factor], eax
}
;--------------------------Get VALUE through power series-------------------
macro GetValue {
local valueLoop, endValueLoop
xor ecx, ecx
;mov ecx, [n]
FILD [pow]
FSTP [current]
Pow
FILD [pow]
Factorial n
FIDIV [factor]
FCHS
FSTP [tmp]
FLD [current]
FSTP [prev]
FLD [current]
FADD [tmp]
FSTP [current]
;Print strD, dword[tmp], dword[tmp+4]
inc dword[n]

valueLoop:
            FLD [prev]
            FSUB [current]
            FABS
            FCOMP qword [delta]
            FSTSW ax
            sahf
            jb endValueLoop


            FLD [current]
            FSTP [prev]

            FLD [tmp]
            FIMUL [x]
            FIDIV [n]
            FCHS
           ; Print strScan, [factor]
            FSTP qword [tmp]
            ;Print strD, dword[tmp], dword[tmp+4]
            FLD [current]
            FADD [tmp]

            inc dword[n]

            FSTP qword [current]
            jmp valueLoop

endValueLoop:
            FLD [current]
            FSTP qword [myValue]

}

;--------------------------Get check VALUE----------------------------------------
macro GetCheckValue param {
local checkLoop, endCheckLoop
xor ecx, ecx
mov ecx, [n]
FLD [e]
checkLoop:
            cmp ecx, [param]
            je endCheckLoop
            FMUL [e]
            ;Print strScan, [n]
            inc ecx
            jmp checkLoop
endCheckLoop:
     FSTP [tmp]
     FILD [n]
     FDIV [tmp]
     FSTP [checkValue]
}

;--------------------------Pow---------------------------------------------------
macro Pow {
      mov eax, [pow]
      imul eax, [x]
      mov [pow], eax
}
;---------------------------------Main-------------------------------------
Error:
       Print strError
       jmp finish
start:
       FINIT
       Print strAuthor
       Print strIntro
       Print strGetParam
       Scan strScan, x
       xor ecx, ecx
       mov ecx, [x]
       cmp ecx, [leftB]
       jl Error
       cmp ecx, [rightB]
       jg Error
       Print strParam, [x]
       ;GetCheckValue x
       GetValue
       Print strSer ,[x], dword[myValue] , dword[myValue+4]

       ;Print strCheck ,[x], dword[checkValue] , dword[checkValue+4]

finish:
       call [getch]
       push 0
       call [ExitProcess]

;--------------------------------------------------------------------------

                                

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'