.section .text
  .global main
  .extern printf
  .extern socket
  .intel_syntax noprefix

main:
  push ebp                            # setting up the stack frame
  mov ebp, esp
  sub esp, 2092
 
  push 0                              # use protocol 0 (whatever that means) 
  push 1                              # SOCK_STREAM (use tcp)
  push 2                              # AF_INET (ipv4)
  call socket
  mov DWORD PTR [ebp-4], eax          # save the return value
  sub esp, 0xc                        # pop off those arguments
 
  push eax
  push OFFSET format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments
 
  mov DWORD PTR [ebp-18], 0           # 
  mov DWORD PTR [ebp-14], 0           # Zero the padding?
  mov WORD PTR [ebp-10], 0            # 

  mov WORD PTR [ebp-24], 2            # set sin_family to AF_INET
  mov WORD PTR [ebp-20], 0            # set sin_addr.s_addr to HTONL(INADDR_ANY)

  mov WORD PTR [ebp-22], 0x0539       # set port to 1337

  nop
  leave
  ret

.data
  tst: .string "lawl"
  format: .string "%d\n"
