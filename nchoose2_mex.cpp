/* LG011108
 * Combination (n choose 2)
 *
 * [Chosen_Ind] = Choose_n_2(n, ny)
 *
 */

#include <stdio.h>
#include "mex.h"

/* Input Arguments */

#define N_IN       prhs[0]
#define NY_IN      prhs[1]


/* Output Arguments */

#define IND_OUT        plhs[0]

static void Choose_n_2(
        unsigned short *Chosen_Ind,
        int n,
        int ny
        ) {
    int i=0;
    int P1, P2;
    for(P1=1;P1<=n;P1++) {
        for(P2=1;P2<=n;P2++) {
            if (P1<P2) {
                Chosen_Ind[2*i]=(unsigned short)P1;
                Chosen_Ind[2*i+1]=(unsigned short)P2;
                i++;
            }
        }
    }
    return;
}

void mexFunction(
        int nlhs,       mxArray *plhs[],
        int nrhs, const mxArray *prhs[]
        ) {
    
    /* define the C variables corresponding to the original matlab variables */
    unsigned short *Chosen_Ind;
    int n;
    double dny;
    int  ny;
    
    /* Check for proper number of arguments */
    if (nrhs != 2) {
        mexErrMsgTxt("Choose_n_3 requires two input arguments: n, and y (num and den of tf).");
    } else if (nlhs > 1) {
        mexErrMsgTxt("Choose_n_3 requires only one output argument.");
    }
    
    n = (int) mxGetScalar(N_IN);    // since input N_IN is a scalar, just read the value.
    ny = (int) mxGetScalar(NY_IN);  //
    
    /* Create a matrix for the return argument */
    IND_OUT = mxCreateNumericMatrix(2, ny, mxUINT16_CLASS, mxREAL);
    /* Assign pointers to the various parameters */
    Chosen_Ind = (unsigned short *)mxGetPr(IND_OUT);
    
    /* Do the actual computations in a subroutine */
    Choose_n_2(Chosen_Ind, n, ny);
    return;
}
