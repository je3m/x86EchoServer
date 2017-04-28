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
  push OFFSET socket_format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments
 
  mov DWORD PTR [ebp-18], 0           # 
  mov DWORD PTR [ebp-16], 0           # 
  mov DWORD PTR [ebp-14], 0           # zero out the padding part?
  mov DWORD PTR [ebp-12], 0           # 
  mov DWORD PTR [ebp-10], 0           # 


  mov WORD PTR [ebp-24], 2            # set sin_family to AF_INET
  mov WORD PTR [ebp-20], 0            # set sin_addr.s_addr to HTONL(INADDR_ANY)

  mov WORD PTR [ebp-22], 0x3905       # set port to 1337

  push 16                             # sizeof sockaddr_in
  lea eax, [ebp-24]                   # load the struct to eax
  push eax                            # pass that in yo
  push [ebp-4]                        # pass file descriptor
  call bind
  sub esp, 0xc

  push eax
  push OFFSET bind_format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments

  push 1                              # one connection queue
  push [ebp-4]                        # push socket fd
  call listen

  push eax
  push OFFSET listen_format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments

  push OFFSET client_addr_size
  lea eax, [ebp-40]                   # load the struct to eax
  push eax                            # pass that in yo
  push [ebp-4]                        # socket fd
  call accept
  sub esp, 0xc
  mov [ebp-8], eax                    # save the conn for later

  push eax
  push OFFSET accept_format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments

  push 0                              # 0 flags 
  push 2048                           # msg buffer length
  mov ebx, ebp
  sub ebx, 2088
  push ebx                            # buffer address
  push DWORD PTR [ebp-8]              # client socket descriptor
  call recv
  sub esp, 0xf  

  push eax
  push OFFSET recv_format
  call printf                         # print the msg len
  sub esp, 0x8                        # pop off those arguments

  mov ebx, ebp
  sub ebx, 2088
  push ebx                            # buffer address 
  push OFFSET print_msg_format
  call printf                         # print the msg len
  sub esp, 0x8                        # pop off those arguments

  push 4                              # close client socket
  call close
  sub esp, 0x4

  push 3                              # close listen socket
  call close
  sub esp, 0x4

  nop
  leave
  ret

.data
  client_addr_size: .short 16
  tst: .string "lawl"
  socket_format: .string "socket return value: %d\n"
  bind_format: .string "bind return value: %d\n"
  listen_format: .string "listen return value: %d\n"
  accept_format: .string "accept return value: %d\n"
  recv_format: .string "msg length: %d\n"
  print_msg_format: .string "message was: %s\n"
