.section .text
  .global main
  .intel_syntax noprefix

main:
  push ebp                            # setting up the stack frame
  mov ebp, esp
  sub esp, 2092

  lea esi, no_mutate

  mov eax, [ebp+8]                    # grab argc
  cmp eax, 1                          # no arguments
  je done_loading_so

  mov eax, DWORD PTR [ebp+12]         # dereference argv
  add eax, 4                          # go forward one byte
  mov eax, DWORD PTR [eax]            # dereference to get argv[1]
  mov esi, eax                        # save that value

  push 2                              # load the library now
  push esi                            # file path to .so
  call dlopen
  sub esp, 0x8
  mov esi, eax                        # save the handle

  push OFFSET print_name_symbol       #
  push esi                            #
  call dlsym                          # call the print_name method on lib
  sub esp, 0x8                        #
  call eax                            #

  push OFFSET mutate_symbol
  push esi
  call dlsym
  sub esp, 0x8
  mov esi, eax                        # save the pointer to mutate function

done_loading_so:
 
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

listen_loop:
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

  call fork 
  cmp eax, 0
  jne listen_loop

  push eax
  push OFFSET accept_format
  call printf                         # print the file descriptor
  sub esp, 0x8                        # pop off those arguments

loop:
  push 0                              # 0 flags 
  push 2048                           # msg buffer length
  mov ebx, ebp
  sub ebx, 2088
  push ebx                            # buffer address
  push DWORD PTR [ebp-8]              # client socket descriptor
  call recv
  sub esp, 0xf
  mov edi, eax                        # save length of the message
  add eax, ebp                        # calculate address to place null 
  sub eax, 2088                       # terminator
  mov DWORD PTR [eax], 0              # place null

  push edi
  push OFFSET recv_format
  call printf                         # print the msg len
  sub esp, 0x8                        # pop off those arguments

  mov ebx, ebp
  sub ebx, 2088
  push ebx                            # buffer address 
  push OFFSET print_msg_format
  call printf                         # print the msg len
  sub esp, 0x8                        # pop off those arguments

  push ebx                            #
  call esi                            # call mutate
  pop ebx                             #

  push 0                              # set flags
  push edi                            # size of message
  push ebx                            # address of message
  mov eax, DWORD PTR [ebp-8]
  push eax                            # connection fd
  call send
  sub esp, 0xf

  cmp edi, 0
  jg loop

  push OFFSET closing_message
  call printf                         # print the msg len
  sub esp, 0x4

  push 4                              # close client socket
  call close
  sub esp, 0x4

  push 3                              # close listen socket
  call close
  sub esp, 0x4

  nop
  leave
  ret

no_mutate:
  push ebp
  mov ebp, esp
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
  closing_message: .string "connection lost, closing...\n"
  arg_number: .string "%d args\n"
  print_name_symbol: .string "print_name"
  mutate_symbol: .string "mutate"
