/**
 * File  :  mosaic.cpp
 * Brief :  convert a figure in RGB color space to bayer format 
 * Author:  Biao Wang 
 * Email :  biaowang@win.tu-berlin.de
 * Date  :  21/09/2017
 *
 * Copyright by Architektur Eingebetteter Systeme (AES) research group
 *
 * Technische Universität Berlin
 * Architektur Eingebetteter Systeme (AES)
 * Einsteinufer 17
 * 10587 Berlin
 * Deutschland
 */

#include <stdlib.h>  
#include <stdio.h>  
#include <math.h>  
#include <cv.h>  
#include "highgui.h"
#include "opencv2/imgproc.hpp"
#include <time.h>

using namespace cv;

enum channels {B=0, G, R};

/* *
 * @brief demosaicing image in bayer format usingUsing bilinear interpolation
 *
 * Bayer format: assuming RGGB pattern, according to the sample element
 * in the first 2x2 block
 * R G R G    // all R located at even rows and even columns
 * G B G B    // all B located at odd  rows and odd  columns
 * R G R G
 * G B G B
 * */
template <typename T>
void bilinear_BayerRGGB2BGR(T* src, T* dst, const int width, const int height){
	bool blue = true;
	int strideSrc = width;
	int strideDst = 3*width;
	int vR, vB, vG;
	printf("parameters width %d, height %d, strideSrc %d, strideDst %d\n", width, height, strideSrc, strideDst);
	for(int j=1; j<(height-1);j++){
        // start interpolation from the second pixel in each line
        if(blue){  // contain B in bayer format
    		for(int i=1; i<(width-1); i+=2){
    		  T *cSrc = src + j*strideSrc+i;// locate the position of current pixel
    		  T *cDst = dst + j*strideDst+i*3;
    		  //deal with the following pixel, where only B sample is available
    		  /* *
    		   * R G R
    		   * G|B|G
    		   * R G R
    		   * * */
              vG = (cSrc[-strideSrc]   + cSrc[strideSrc] + cSrc[-1] + cSrc[1] + 2) >>2 ;
              vR = (cSrc[-strideSrc-1] + cSrc[-strideSrc+1] + cSrc[strideSrc-1] + cSrc[strideSrc+1] + 2) >>2 ;

              cDst[B] = cSrc[0]; // copy B
              cDst[G] = (T)vG;
              cDst[R] = (T)vR;
              if(i==1&&j==1)
            	  printf("first value output R G B %d %d %d\n", cDst[R], cDst[G], cDst[B]);
              //deal with the next horizontal pixel, where only G sample is available
    		  /* *
    		   * R G R G
    		   * G B|G|B
    		   * R G R G
    		   * * */
              cSrc+=1; cDst+=3;
              vB = (cSrc[-1] + cSrc[1] + 1) >> 1;
              vR = (cSrc[-strideSrc] + cSrc[strideSrc] + 1) >> 1;

              cDst[B] = (T)vB;
              cDst[G] = cSrc[0]; // copy G
              cDst[R] = (T)vR;
    		}
        }else{ // not contain B in bayer format
    		for(int i=1; i<(width-1); i+=2){
    		  T *cSrc = src + j*strideSrc+i;// locate the position of current pixel
    		  T *cDst = dst + j*strideDst+i*3;
    		  //deal with the following pixel, where only G sample is available
    		  /* *
    		   * G B G
    		   * R|G|R
    		   * G B G
    		   * * */
              vB = (cSrc[-strideSrc] + cSrc[strideSrc] + 1) >> 1;
              vR = (cSrc[-1] + cSrc[1] + 1) >> 1;

              cDst[B] = (T)vB;
              cDst[G] = cSrc[0]; // copy G
              cDst[R] = (T)vR;

              //deal with the next horizontal pixel, where only R sample is available
    		  /* *
    		   * G B G B
    		   * R G|R|G
    		   * G B G B
    		   * * */
              cSrc+=1; cDst+=3;
              vG = (cSrc[-strideSrc] + cSrc[strideSrc] + cSrc[-1] + cSrc[1] + 2) >>2 ;
              vB = (cSrc[-strideSrc-1] + cSrc[-strideSrc+1] + cSrc[strideSrc-1] + cSrc[strideSrc+1] + 2) >>2 ;

              cDst[B] = (T)vB;
              cDst[G] = (T)vG;
              cDst[R] = cSrc[0]; // copy R
    		}
        }
		//fill the first and last pixel of each row
		T *cDst = dst + j*strideDst;
		cDst[B] = cDst[3+B];
		cDst[G] = cDst[3+G];
		cDst[R] = cDst[3+R];
		cDst[(width-1)*3+B] = cDst[(width-2)*3+B];
		cDst[(width-1)*3+G] = cDst[(width-2)*3+G];
		cDst[(width-1)*3+R] = cDst[(width-2)*3+R];
		blue=!blue;
	}
	// fill the first and last row of rgb
	for (int i=0; i< strideDst; i++){
		dst[i] = dst[i+strideDst];
		dst[(height-1)*strideDst + i] = dst[(height-2)*strideDst + i];
	}
}

int main(int argc, char *argv[])  
{  
    IplImage* bayerImg = 0;   
    IplImage* debayerImg;
    int height,width,step,channels,depth;  
    if(argc<2)  
    {  
        printf("Usage: opencv_demosaic <image-file-name>\n");
        exit(0);  
    }  
    // Load image   
    bayerImg=cvLoadImage(argv[1],-1);  
    if(!bayerImg)  
    {  
        printf("Could not load image file: %s\n",argv[1]);  
        exit(0);  
    }  
    // acquire image info  
    height    = bayerImg->height;    
    width     = bayerImg->width;
    step      = bayerImg->widthStep;
    channels  = bayerImg->nChannels;
    depth     = bayerImg->depth;
//    printf("Processing a %dx%d image with %d channels bitdepth %d\n",height,width,channels, depth);
    // Convert from RGGB to RGB, i.e.,
    /* R G R G       // all R located at even rows and even columns 
     * G B G B       // all B located at odd  rows and odd  columns     
     * R G           // otherwise, are G points.
     * G B
     * -----
     */        
    // the original figure has channels in BGR order 
    debayerImg        = cvCreateImage(cvSize(width, height), depth, 3);
    struct timespec ts_start, ts_end;
    double start, end;
    clock_gettime(CLOCK_REALTIME, &ts_start);
    if(depth==8){
    	bilinear_BayerRGGB2BGR<uchar>((uchar *)bayerImg->imageData, (uchar *)debayerImg->imageData, width, height);
    }else{
    	bilinear_BayerRGGB2BGR<ushort>((ushort *)bayerImg->imageData, (ushort *)debayerImg->imageData, width, height);
    }
    clock_gettime(CLOCK_REALTIME, &ts_end);
    start = (double)ts_start.tv_sec  + (double)ts_start.tv_nsec / 1000000.0;
    end   = (double)ts_end.tv_sec    + (double)ts_end.tv_nsec / 1000000.0;
    printf("CPU bilinear filtering time %.3f ms \n", end-start); 
    cvSaveImage("debayered.png", debayerImg);
    cvReleaseImage(&bayerImg);  
    cvReleaseImage(&debayerImg);
//    printf("height=%d  width=%d step=%d channels=%d\n",height,width,step,channels);
    return 0;  
}  
