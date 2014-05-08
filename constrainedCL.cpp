// Implements the constrained clustering by Klein et al ICML 2002.
// http://www.cs.berkeley.edu/~klein/papers/constrained_clustering-ICML_2002.pdf
// Juan Carlos Niebles
#include <mex.h>
#include <vector>
#include <float.h>
#include "timer.h"

#include <algorithm>

/* Input Arguments */
#define Distances_IN    prhs[0]
#define Constrains_IN   prhs[1]
#define Threshold_IN	prhs[2]
// Constrains given as a Matrix, where
// C(i,j) = C(j,i) = -1 if x_i cannot link with x_j
// C(i,j) = C(j,i) = 1  if x_i must link with x_j
// C(i,j) = C(j,i) = 0  otherwise

/* Output Arguments */
#define clusterID_OUT   plhs[0]


void inline imposeMustLinks(double *D, double *C ,unsigned int nPoints)
{
    for (unsigned int i=0;i<nPoints;i++)
        for (unsigned int j=0;j<nPoints;j++)
    {
        if (C[i + j*nPoints] == 1) //must link
        {
            D[i + j*nPoints] = 0;
            D[j + i*nPoints] = 0;
        }
	}
}

void inline imposeCannotLinks(double *D, double *C ,unsigned int nPoints)
{
    //check this part, why the second pair with k?

    for (unsigned int i=0;i<nPoints;i++)
        for (unsigned int j=i+1;j<nPoints;j++)
    {
        if (C[i + j*nPoints] == -1) //cannot link
        {
            D[i + j*nPoints] = DBL_MAX;
            D[j + i*nPoints] = DBL_MAX;
			for (unsigned int k=0;k<nPoints;k++)
			{
				if (C[j + k*nPoints] == 1) //must link
				{
					D[i + k*nPoints] = DBL_MAX;
					D[k + i*nPoints] = DBL_MAX;
				}
			}
        }
    }
}

void inline fastAllPairShortestPaths(double *D, double *C ,unsigned int nPoints)
{
    for (unsigned int i=0;i<nPoints;i++)
    {
        bool sw = false;
        for (unsigned int j=0;j<nPoints;j++)
        {
            if ( (C[i + j*nPoints] == 1) && (i!=j) )
            {
                sw = true;
                break;
            }
        }
        if (sw)
        {
            for (unsigned int m=0;m<nPoints;m++)
                for (unsigned int n=m+1;n<nPoints;n++)
            {
                D[m + n*nPoints] = std::min(D[m + n*nPoints], D[m + i*nPoints] + D[i + n*nPoints]);
                D[n + m*nPoints] = D[m + n*nPoints];
            }
        }
    }
}

void inline propagateMustLinks(double *D, double *C ,unsigned int nPoints)
{
    //timer mytimer;
    //mytimer.start("shortest paths");
    fastAllPairShortestPaths(D,C,nPoints);
    //mytimer.check();
    
    for (unsigned int i=0;i<nPoints;i++)
        for (unsigned int j=i+1;j<nPoints;j++)
    {
        if (D[i + j*nPoints] == 0)
        {
            C[i + j*nPoints] = 1;
            C[j + i*nPoints] = 1;
        }
    }
}


//void inline propagateCannotLinks(double *D, double *C ,unsigned int nPoints) { };
    
void inline completeLink(double *D, double *clusterIds , unsigned int nPoints, double threshold)
{
    //std::vector<unsigned int> clusters;
    //std::vector<std::vector<unsigned int> > linkage;
    
    //std::vector<int > memberships(nPoints,0);
    
    for(unsigned int i=0;i<nPoints;i++)
        clusterIds[i] = i;
    
    std::vector<double> dummy (nPoints,0);
    std::vector< std::vector<double> > distances(nPoints,dummy);
    
    for(unsigned int i=0;i<nPoints;i++)
        for (unsigned int j=i+1;j<nPoints;j++)
    {
        distances[i][j] = D[i + j*nPoints];
        distances[j][i] = D[j + i*nPoints];
    }
    
    unsigned int k=0;
    while(1)
    {
        double minDist = DBL_MAX;
        unsigned int minidx[2];
        minidx[0] = 0;
        minidx[1] = 0;
        
        //find closest pair
        for(unsigned int i=0;i<nPoints;i++)
            for (unsigned int j=i+1;j<nPoints;j++)
        {
            if (distances[i][j]<minDist)
            {
                minidx[0] = i;
                minidx[1] = j;
                minDist = distances[i][j];
            }
        }
        if (minDist>threshold)
            break;
        
        //merge
        unsigned int newID = minidx[0];
        unsigned int oldID = minidx[1];

        //update membership
        for (unsigned int i=0;i<nPoints;i++)
        {
            if (clusterIds[i] == oldID)
            {
                clusterIds[i] = newID;
            }
        }
        //update distance of new cluster
        for(unsigned int i=0;i<nPoints;i++)
        {
            if ((i==newID)||(i==oldID) ) continue;
            distances[i][newID] = std::max(distances[i][newID],distances[i][oldID]);
            distances[newID][i] = distances[i][newID];
        }
        // 'erase' old cluster by putting large distance
        for(unsigned int i=0;i<nPoints;i++)
        {
			distances[oldID][i] = DBL_MAX;
			distances[i][oldID] = DBL_MAX;
        }
        k++;
        if (k>nPoints)
        {
            return;
        }
    }
    
    
}

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* check: only one input and one output argument */
    if (nrhs !=3)
        mexErrMsgTxt("Must have 3 input arguments");
    if (nlhs !=1)
        mexErrMsgTxt("Must have 1 output argument");
    
    /* Get inputs*/
    // Check data types
    if (!mxIsDouble(Distances_IN) || mxIsComplex(Distances_IN)){
        mexErrMsgTxt("Inputs must be double.");
    }
    if (!mxIsDouble(Constrains_IN) || mxIsComplex(Constrains_IN)){
        mexErrMsgTxt("Inputs must be double.");
    }
    
    // Check first input
    int nDims = mxGetNumberOfDimensions(Distances_IN);
    
    if (nDims!=2) {
        mexErrMsgTxt("First Input must be 2-D.");
    }
    
    double *D = (double*) mxGetPr(Distances_IN);

    
    if ( mxGetN(Distances_IN) != mxGetM(Distances_IN))
    {
        mexErrMsgTxt("First Input must be a squared matrix.");
    }
    
    unsigned int nDataPoints = (unsigned int) mxGetM(Distances_IN);
    
    
    // Check second input
    int nDims2 = mxGetNumberOfDimensions(Constrains_IN);
    if ( (nDims2>2)  ||
         (mxGetM(Constrains_IN)!=mxGetN(Constrains_IN)) || (mxGetN(Constrains_IN)!=nDataPoints) )
    {
        mexErrMsgTxt("Second Input must be squared 2-D matrix, with same size than first Input");
    }
    
    double * C = (double*) mxGetPr(Constrains_IN);
    //mexPrintf("nDataPoints = %d\n",nDataPoints);

	// Check third input
    int numElems= mxGetNumberOfElements(Threshold_IN);
    if (numElems>1)
    {
        mexErrMsgTxt("Third Input must be scalar.");
    }
	double Threshold = (double) mxGetScalar(Threshold_IN);
    
    
    clusterID_OUT = mxCreateNumericMatrix(nDataPoints, 1, mxDOUBLE_CLASS,mxREAL);
    double *clusterIds = (double *) mxGetPr(clusterID_OUT);
    
    // -------------------------- Main Algorithm --------------------- //
    
    //
    timer mytimer;
    mytimer.start("imposing Must Links");
    imposeMustLinks(D,C, nDataPoints);
    mytimer.check();
	mytimer.restart();
    
    mytimer.start("propagating Must Links");    
    propagateMustLinks(D,C,nDataPoints);
    mytimer.check();
	mytimer.restart();
    
    mytimer.start("imposing Cannot Links");    
    imposeCannotLinks(D,C,nDataPoints);
    mytimer.check();
	mytimer.restart();
    //propagateCannotLinks(D,C,nDataPoints);

    mytimer.start("complete-linkage clustering");    
    completeLink(D,clusterIds,nDataPoints,Threshold);
    mytimer.check();
    /*
    std::vector<int > centerPoints(nDataPoints,0);
    std::vector<int > memberships(nDataPoints,0);
    
    // intial centers and clusters
    for (unsigned int i=0;i<nDataPoints;i++)
    {
        memberships[i] = i;
        centerPoints[i] = i;
    }
    */
    
    /*
    // compute distance matrix
    double * distance = new double[nDataPoints*nDataPoints];
    
    double maxDist = 0;

    for (unsigned int i=0;i<nDataPoints;i++)
    {
        distance[i + i*nDataPoints] = 0;
        
        for(unsigned int j=i+1;j<nDataPoints;j++)
        {
            double sum = 0;

            for(unsigned int d=0; d<1;d++){
                //diff += ;
                sum += ((data[i + d*nDataPoints]- data[j + d*nDataPoints])
                        *(data[i + d*nDataPoints]- data[j + d*nDataPoints]))
                        /(3e-16+data[i + d*nDataPoints] + data[j + d*nDataPoints]);
            }
            distance[i + j*nDataPoints] = sum;
            distance[j + i*nDataPoints] = sum;
            if (sum>maxDist)
                maxDist = sum;
        }
    }
    */
    
    //mexPrintf("centers size = %d\n",centers.size());
    //mexPrintf("clusters size = %d\n",clusters.size());
/*
    int k=0;
    while (1) {
        
        
        double mindist = maxDist;
        unsigned int minidx[2];
        minidx[0] = 0;
        minidx[1] = 0;
        
        // get pair of closest centers
        for (unsigned int i=0; i<nDataPoints; i++)
        {
            if (centerPoints[i]==-1)
                continue;
            for (unsigned int j=i+1; j<nDataPoints; j++)
            {
                if (centerPoints[j]==-1)
                    continue;
                if (mindist>distance[centerPoints[i] + centerPoints[j]*nDataPoints])
                {
                    minidx[0] = i;
                    minidx[1] = j;
                    mindist = distance[centerPoints[i] + centerPoints[j]*nDataPoints];
                }
            }
        }
        //mexPrintf("trh = %g\tmindist = %g\n\n",threshold,mindist);

        // if min dist is larger than threshold, then stop
        if (mindist>threshold)
            break;
        
        // merge clusters by updating membership
        unsigned int new_clust = minidx[0];
        unsigned int old_clust = minidx[1];

        //mexPrintf("join clust %d and %d\n",new_clust,old_clust);

        for (unsigned int i=0;i<nDataPoints;i++)
        {
            //if ((memberships[i] == minidx[0]) || (memberships[i] == minidx[1]) )
            if (memberships[i] == old_clust)
            {
                memberships[i] = new_clust;
            }
        }
        
        // eliminate old center
        centerPoints[old_clust] = -1;
        
        // update cluster center
        unsigned int bestCenter = 0;
        double bestDist = maxDist*nDataPoints+1;
        
        for (unsigned int i=0;i<nDataPoints;i++)
        {

            if (memberships[i] != minidx[0])
                continue;
            //mexPrintf("comparing: %d\t",i);
            double thisDist = 0;
            for (unsigned int j=0; j<nDataPoints; j++)
            {
                if (memberships[j] != minidx[0])
                    continue;
                thisDist += distance[i + j*nDataPoints];
                //mexPrintf("%d\t",j);
            }
            if (thisDist<bestDist)
            {
                bestCenter = i;
                bestDist = thisDist;
            }
            //mexPrintf("\n");
        }
        
        centerPoints[new_clust] = bestCenter;
        //mexPrintf("new center is %d\n",bestCenter);
        k++;
        if (k>nDataPoints)
        {
            //mexPrintf("wtf?\n");
            return;
        }
    }
    
    delete [] distance;
*/    
    //initialize output
    /*
    centers_OUT = mxCreateNumericMatrix(nDataPoints, 1, mxDOUBLE_CLASS,mxREAL);
    double *centersOut = (double *) mxGetPr(centers_OUT);

    for (unsigned int idx = 0; idx< nDataPoints;idx++)
    {
        centersOut[idx] = centerPoints[idx]+1;
    }
    
    clusterID_OUT = mxCreateNumericMatrix(nDataPoints, 1, mxDOUBLE_CLASS,mxREAL);
    double *clusterIdOut = (double *) mxGetPr(clusterID_OUT);

    
    for (unsigned int idx = 0; idx< nDataPoints;idx++)
    {
        clusterIdOut[idx] = memberships[idx]+1;
    }
    */
}

