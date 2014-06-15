#include "mex.h"
#include <stdlib.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    long int Npoints, L, N, i, j, k;
    double *data, *dist2s, *temp;
    
    data = mxGetPr(prhs[0]);

    
    Npoints = mxGetM(prhs[0]);
    L = mxGetN(prhs[0]);
    
    
    plhs[0] = mxCreateDoubleMatrix(Npoints,Npoints,mxREAL);
    dist2s = mxGetPr(plhs[0]);    
    
    for (k=0; k<Npoints; k++) {
        for (j=(k+1); j<Npoints; j++) {
            dist2s[j*Npoints+k] = 0;
            for (i=0; i<L; i++)
                dist2s[j*Npoints+k] += (data[i*Npoints+j]-data[i*Npoints+k])*(data[i*Npoints+j]-data[i*Npoints+k]);
            
            dist2s[j*Npoints+k] = sqrt(dist2s[j*Npoints+k]);
            dist2s[k*Npoints+j] = dist2s[j*Npoints+k];
        }
    }
}


