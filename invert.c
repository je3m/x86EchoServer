#include <stdio.h>

void print_name() {
  printf("Loaded invert.so\n");
}

//function that inverts everything
void mutate(char* in) {
  int i = 0;
  while(in[i] != '\n') {
    in[i] ^= ' ';
    i++;
  }
}
