#include <stdio.h>

void print_name() {
  printf("Loaded allcaps.so\n");
}

//function that capitalize everything
void mutate(char* in) {
  int i = 0;
  while(in[i] != '\0') {
    in[i] ^= in[i] & ' ';
    i++;
  }
}
