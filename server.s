.section .text
  .global main
  .extern printf
  .extern socket
  .intel_syntax noprefix

main:
  push ebp
  mov ebp, esp
  sub esp, 2092
 
  push 0                              #use protocol 0 
  push 1                              #SOCK_STREAM (use tcp)
  push 2                              #AF_INET (ipv4)
  call socket
  mov DWORD PTR [ebp-4], eax            #save the return into sock
  sub esp, 0xc                        #pop off those arguments
 
  push eax
  push OFFSET format
  call printf
  sub esp, 0x8                        #pop off those arguments
 
  nop
  leave
  ret

.data
  tst: .string "lawl"
  format: .string "%d\n"
