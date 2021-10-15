SYS_READ        =  0
SYS_WRITE       =  1
SYS_EXIT        =  60
STDOUT          =  1
STDIN           =  0
EXIT_SUCCESS    =  0

.global _start

  .text
print: # write(fd, buff, len)
  push %rbp
  mov %rsp, %rbp
  mov 16(%rbp), %rdx      # len
  mov 24(%rbp), %rsi      # str
  mov $SYS_WRITE, %rax
  mov $STDOUT, %rdi
  syscall
  pop %rbp
  ret
scan: # read(fd, buff len)
  push %rbp
  mov %rsp, %rbp
  mov 16(%rbp), %rdx      # len
  mov 24(%rbp), %rsi      # str
  mov $SYS_READ, %rax
  mov $STDIN, %rdi
  syscall
  mov %rax, %rbx
  mov %rbx, len_read_name # len_read_name = write(...);
  pop %rbp
  ret
concat:
  xor %rcx, %rcx          # counter
add_welcome:
  mov welcome(%rcx), %al  # append welcome to hi
  mov %al, hi(%rcx)
  inc %rcx
  cmp $len_welcome, %rcx
  jl add_welcome
  xor %rdx, %rdx
add_name:
  mov name(%rdx), %al     # append name to hi
  mov %al, hi(%rcx)
  inc %rcx
  inc %rdx
  cmp len_read_name, %rdx
  jl add_name
  ret

  .data
OVERFLOW:
  .string "Name too long...\n"
len_overflow = . -OVERFLOW
EMPTY:
  .string "No Name given...\n"
len_empty = . -EMPTY
len_read_name: .int
clear_buff: .int        # store the byte to clear stdin

  .text
clear_stdin:            # clear stdin reading byte per byte
  mov $SYS_READ, %rax
  mov $STDIN, %rdi
  mov clear_buff, %rsi
  mov $1, %rdx
  syscall
  mov $clear_buff, %rsi
  cmp $'\n', %rsi       # if byte != '\n' -> continue
  jnz clear_stdin
  ret
print_empty:            # show the string is empty
  push $EMPTY           # actually only '\n'
  push $len_empty
  call print
  call exit
print_non_ok:           # show the name is too long
  push $OVERFLOW
  push $len_overflow
  call print
  call clear_stdin
  ret
check_overflow:
  mov len_name, %rcx      # rcx = len_name
  mov name(%rcx), %rax    # rax = name[last]
  cmp $'\n', %rax         # if rax != '\n'
  jne print_non_ok        # non ok
  ret                     # else return
check_length:
  mov len_read_name, %al
  mov len_name, %bl
  cmp %al, %bl            # if they have the same length
  jz check_overflow       # check overflow
  ret
check_empty:
  xor %rdx, %rdx
  mov name(%rdx), %eax    # eax = name[0]
  cmp $10, %eax           # if eax == '\n'
  jz print_empty          # warning + exit
  ret
exit: # exit(status)
  mov $SYS_EXIT, %rax
  mov $EXIT_SUCCESS, %rdi
  syscall
_start: # main function
  push $ask 
  push $len_ask
  call print              # print question
  push $name
  push $len_name
  call scan               # ask the name
  call check_empty        # check if the name is empty
  # check_length is still in progress
  #call check_length       # check if the name is too long
  call concat             # concatenate the Hi and the name
  push $hi
  push $len_hi
  call print              # print hi + name
  call exit               # exit

  .data
ask: 
  .string "What is your name : "
len_ask = . -ask
name: .zero  30
len_name = . -name
welcome:
  .string "Hi "
len_welcome = . -welcome
hi: .zero 35                    # will contain welcome+name
len_hi = . -hi
