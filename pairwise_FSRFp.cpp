
#include <math.h>
#include <matrix.h>
#include <mex.h>
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

#if (defined(_LP64) || defined(_WIN64)) && !defined(MX_COMPAT_32)
# define MWSIZE_MAX    281474976710655UL
# define MWINDEX_MAX   281474976710655UL
# define MWSINDEX_MAX  281474976710655L
# define MWSINDEX_MIN -281474976710655L
#else
# define MWSIZE_MAX    2147483647UL
# define MWINDEX_MAX   2147483647UL
# define MWSINDEX_MAX  2147483647L
# define MWSINDEX_MIN -2147483647L
#endif
#define MWSIZE_MIN    0UL
#define MWINDEX_MIN   0UL
#endif

double tgamma(int L)
{
    if ( L < 1 ) 
        return 0;
    double r = 1;
    int i;
    for ( i = 2; i < L; i ++ )
        r = r * i;
    return r;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    //declare variables
    mxArray  *I_m,*I_m_rgb,*I_m_LD, *val, *gf_m, *IW_m, *NI_m, *Paramsptr_m, *m_mask;
    mwSize numdims;
    
    const mwSize *dims;
    const double PI  =3.141592653589793238462;
    double sig;
    double  Ns, Nr;
    double *Nx, *Ny, *NRx, *NRy, *I, *Iout, *pij;
    double *pp, *gf, *IW, *NI, *Paramsptr;
    double sig2, sig3;
    double IWS;
    double maxval, Th, alpha, bU;
    double *sim_thr;
    double *avg;
    double *I_rgb;
    double *I_LD;
    double * mask;
    
    int i, j, k, l, m;
    int dimx, dimy, dimxy, colors;
    int idxq, idxp, idxp1,  idxq1;
    int sPercentage;
    double nct;
    bool bProcess, bProcess2;
    double sigma = 1;
    
    //RADARSAT-1 SCAN-SAR NARROW
//     double L = 4; 
    
    //RADARSAT-1 SCAN-SAR WIDE
    double L = 8; 
    // ?
    double maxP = 3.3516;
    
    //gets image dimensions
    numdims = mxGetNumberOfDimensions(prhs[0]);
    dims = mxGetDimensions(prhs[0]);
    dimy = (int)dims[0];
    dimx = (int)dims[1];
    dimxy = dimx*dimy;
    
    Paramsptr_m = mxDuplicateArray(prhs[4]);
    Paramsptr = mxGetPr(Paramsptr_m);
    
    Ns = Paramsptr[0];
    Nr = Paramsptr[1];
    sig = Paramsptr[2];
    sPercentage = Paramsptr[3];
    Th = Paramsptr[4];
    sigma = Paramsptr[5]; 
    sig2 = 0.43*sig*sig;
    sig3 = 6.8*sig*sig;
    IW_m = mxCreateDoubleMatrix(Ns, Ns, mxREAL);
    NI_m = mxCreateDoubleMatrix(Ns, Ns, mxREAL);
    
    IW=mxGetPr(IW_m);
    NI=mxGetPr(NI_m);
    
    plhs[0] = mxCreateDoubleMatrix(dimy, dimx, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(Ns, Ns, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(Ns, Ns, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(Nr, Nr, mxREAL);
    plhs[4] = mxCreateDoubleMatrix(Nr, Nr, mxREAL);
    plhs[5] = mxCreateDoubleMatrix(Ns, Ns, mxREAL);
    I_m = mxDuplicateArray(prhs[0]);
    I_m_rgb = mxDuplicateArray(prhs[1]);
    I_m_LD = mxDuplicateArray(prhs[2]);
    m_mask = mxDuplicateArray(prhs[3]);
    
    I = mxGetPr(I_m);
    I_rgb = mxGetPr(I_m_rgb);
    I_LD = mxGetPr(I_m_LD);
    mask = mxGetPr(m_mask);
    
    double ss = pow(Nr,2); // scale label density similarity
    
    Nx=mxGetPr(plhs[1]);
    Ny=mxGetPr(plhs[2]);
    
    NRx=mxGetPr(plhs[3]);
    NRy=mxGetPr(plhs[4]);
    pij = mxGetPr(plhs[5]);
    Iout = mxGetPr(plhs[0]);
    for (int i = 0; i!=dimx*dimy;i++) {
        Iout[i]=0;
    }
    double tgamma2L_1 = tgamma(2*L-1);
    double tgammaL = tgamma(L);
    double C = sqrt(2*PI);
    double C2 = 4*L* tgamma2L_1  / pow(tgammaL,2)/ maxP;
    
   /*Generate the search location index and patch index related with the current point*/ 
    for(int m=0;m<Ns;m++){
        for(int n=0;n<Ns;n++){
            idxp = (n)+(m)*Ns;
            Nx[idxp] = m-floor(Ns/2); //Nx and Ny define the relative pixel position in searching area relative to the referenced pixel
            Ny[idxp] = n-floor(Ns/2);
        }
    }
    for(int m=0;m<Nr;m++){
        for(int n=0;n<Nr;n++){
            idxp = (n)+(m)*Nr;
            NRx[idxp] = m-floor(Nr/2); //NRx and NRy define the relative pixel position in imgae patch relative to the referenced pixel
            NRy[idxp] = n-floor(Nr/2);
        }
    }


  /*iterate the input image*/
   int kk = -1;
   int pnumber = 0;
   int count = 0;
   // int offset = Ns*Ns;
   int nsb2 = floor(Ns/2)+1+floor(Nr/2)+1; //the patch location bundary buffer size
    for(i=nsb2;i<dimx-nsb2;i++) {
        for(j=nsb2;j<dimy-nsb2;j++) {
        // for each pixel in the domain
            idxp = j+i*dimy; // current pixel index: y_i
            maxval = 0;
            kk++;
            count = 0;
            if (mask[idxp]>0.1)
            {
                Iout[idxp] = I[idxp];
                continue;
            }
            for(m=0;m<(Ns*Ns);m++) { //iterative all pixels in searching area
                bProcess = false;
                idxq = idxp + Nx[m]*dimy + Ny[m]; //get the position of sampled pixel in image space, y_j
                IWS=0;
                if (idxq==idxp) {
                    continue;
                }
                if (mask[idxq]>0.1)
                {
                    continue;
                }
                else {
                    // nct = 0;
                    // used to randomly threhold the spatial distance between the 
                    // referenced pixel and the sampled pixel
                    // ?? where is the sigma for C, and C is not 1/C?
                    // the fraction is fully controled by the distance
                    double frac = C * exp(-1*(Nx[m]*Nx[m] + Ny[m]*Ny[m])/(2*sigma*sigma)); 
                    bProcess = (rand()%100+1<frac*sPercentage);
                    if (bProcess) { 
                        count++;
                        for(int n=0; n<(Nr*Nr);n++) {
                            // get the position of pixels in the referenced image patch
                            idxp1 = idxp + NRx[n]*dimy + NRy[n];
                            // get the position of pixels in the sampled image patch
                            idxq1 = idxq + NRx[n]*dimy + NRy[n]; 
                            double b1 = pow(I_rgb[idxp1],0.5);
                            double b2 = pow(I_rgb[idxq1],0.5);
                            double incremt  = pow(I_rgb[idxp1]-I_rgb[idxq1],2);
                            IWS = IWS+incremt; 
                            // nct = nct+1;
                        } 
                    }
                }
                if (bProcess) {
                    bU = rand()%100+1;
                    //IWS = pow(I_rgb[idxp]-I_rgb[idxq],2);
                    // Pij
                    if (IWS == 0) IWS = 9;
                    IW[m] = exp(-IWS*L/(2*sig*sig))*exp(-1*(Nx[m]*Nx[m] + Ny[m]*Ny[m])/(2*sigma*sigma)); // distance from the mth patch-sample to the referenced patch               
                    //IW[m] = exp(-IWS*L/(2*sig*sig));
                    pij[m] = IWS;
                    if (IW[m]*100<bU)  //determine is the probability is significant, if not, set it to 0
                    {
                        IW[m]=0;
                        pij[m] = IWS;
                    }
                    if (IW[m]>maxval)
                        maxval = IW[m];
                    
                    NI[m] = I[idxq];
                }
                else {
                    IW[m]=0;
                }
                
            }
            // pnumber = pnumber + 1;
            if (maxval == 0)
                maxval = 0.01;
            
            IWS =0;
            double w = 0;
            for(k=0;k<Ns*Ns;k++) {
                IWS =IWS+NI[k]*IW[k]; // weighted sum of intensity values of sampled pixels
                w = w+IW[k]; // sum of weight of sampled pixels, with the weight determined by the patch-intensity-similarity
            }
            IWS = IWS+maxval*I[idxp];
            w = w+maxval;

            IWS = IWS/w; // estimate the referenced pixel value as the weighted sum of sampled pixels
            Iout[idxp] =IWS;
        }
    }
    return;
}


