#include <stdio.h>
#include <time.h>

int main() {

int steps = 256 * 1024 * 1024;

int x, y;
x = y = 0;

clock_t start = clock();

#if LOOP1
// Loop 1
 for (int i=0; i<steps; i++) { x++; x++;}


 #elif LOOP2
 // Loop 2
 for (int i=0; i<steps; i++) { x++; y++;}
#endif 

  clock_t end = clock();
  printf("Seconds = %f\n", ((double) end-start)/CLOCKS_PER_SEC);

  return(x+y);
}