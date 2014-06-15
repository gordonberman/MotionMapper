#include "mex.h"
#include <stdlib.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    int Npoints, L, N, i, j, k, Npoints2, L2;
    double *data, *data2, *dist2s, *temp;
    
    data = mxGetPr(prhs[0]);
    data2 = mxGetPr(prhs[1]);

    
    Npoints = mxGetM(prhs[0]);
    L = mxGetN(prhs[0]);
    Npoints2 = mxGetM(prhs[1]);
    L2 = mxGetN(prhs[1]);
    
    if (L != L2)
        mexErrMsgTxt("Dimension of Data Sets Do Not Match!!");
    
    
    plhs[0] = mxCreateDoubleMatrix(Npoints,Npoints2,mxREAL);
    dist2s = mxGetPr(plhs[0]);    
    
    for (k=0; k<Npoints; k++) {
        for (j=0; j<Npoints2; j++) {
            dist2s[j*Npoints+k] = 0;
            for (i=0; i<L; i++)
                dist2s[j*Npoints+k] += (data[i*Npoints+k]-data2[i*Npoints2+j])*(data[i*Npoints+k]-data2[i*Npoints2+j]);
            
            dist2s[j*Npoints+k] = sqrt(dist2s[j*Npoints+k]);
        }
    }
}


