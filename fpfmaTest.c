

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>

typedef union sfpFp {
  unsigned int sfp;
  float fp;
} SFP;


main()
{
    FILE * out;
    out = fopen("sub_inputs.txt","w"); 
    srand(time(NULL));
    int i;
    SFP a,b,c,res; 
    for(i=0;i<100000;i++){
      a.fp= (float)rand()/(float)INT_MAX;
      b.fp=(float)rand()/(float)INT_MAX;
      c.fp=(float)rand()/(float)INT_MAX;
      c.fp=-c.fp;
    
      res.fp=fmaf(a.fp,b.fp,c.fp);
      fprintf(out, "%x %x %x %x\n", a.sfp,b.sfp,c.sfp,res.sfp);

   }


}
