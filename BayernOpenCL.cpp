// BayernOpenCL.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <opencv\cv.h>
#include "opencv\highgui.h"
#include "opencv2\imgproc.hpp"
#include "opencv2\core.hpp"
#include "opencv2\core\ocl.hpp"

#include <CL\cl.h>


#include <time.h>

#include <stdlib.h>  
#include <stdio.h>  
#include <math.h>
#include <iostream>


#ifdef _WIN32
#include <Windows.h>
#endif // _WIN32


using namespace cv;

enum channels { B = 0, G, R };

#define CLOCK_REALTIME 0
#define MAX_SOURCE_SIZE (0x100000)

template <typename T>
void BayerKernel(T* src, T* out, const int width, const int height)
{
	/*for (int count = 0; count < 100; count++)
	std::cout << src[count]<<std::endl;
	return;*/
	//// Create a program from the kernel source
	cv::ocl::setUseOpenCL(true);

	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_platform_id *platforms = NULL;

	int MaxBufferSize = width * height;

	T* dst = (T*)malloc(MaxBufferSize);

	//Open kernel.cl file and store it in local string
	char *source_str = (char*)malloc(MAX_SOURCE_SIZE);
	size_t source_size;
	FILE *fp;
	errno_t errnum = fopen_s(&fp, "kernel.cl", "r");
	fseek(fp, 0, SEEK_END);
	source_size = ftell(fp);
	rewind(fp);
	if (fp == NULL)
		return;
	size_t ReadingSize = fread(source_str, 1, source_size, fp);
	fclose(fp);

	//Create Platform and Context 
	// ret is the Error Code, should be zero or CL_SUCCESS everytime!!!
	cl_int ret = clGetPlatformIDs(0, NULL, &ret_num_platforms);
	platforms = (cl_platform_id*)malloc(ret_num_platforms * sizeof(cl_platform_id));
	ret = clGetPlatformIDs(ret_num_platforms, platforms, NULL);
	ret = clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, 1, &device_id, &ret_num_devices);

	cl_context context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);
	cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);

	// Create a program from the kernel source 	and Build the program
	cl_program program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&ReadingSize, &ret);
	ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

	// Allocate Buffer in GPU
	cl_mem img_Source = clCreateBuffer(context, CL_MEM_READ_ONLY, MaxBufferSize, NULL, &ret);
	cl_mem img_Output = clCreateBuffer(context, CL_MEM_WRITE_ONLY, MaxBufferSize, NULL, &ret);//clCreateBuffer(context, CL_MEM_WRITE_ONLY, MaxBufferSize, out, &ret);


																							  //Create the Kernel to call the function bayer_filter
	cl_kernel kernel = clCreateKernel(program, "bayer_filter", &ret);
	ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&img_Source);
	ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&img_Output);
	ret = clSetKernelArg(kernel, 2, sizeof(cl_int), (void *)&width);

	//Sending Input Buffer from CPU to GPU
	ret = clEnqueueWriteBuffer(command_queue, img_Source, CL_TRUE, NULL, MaxBufferSize, src, 0, NULL, NULL);

	//Execute the Kernel
	size_t global_item_size = 64;
	size_t local_item_size = 64;
	ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, &local_item_size, 0, NULL, NULL);

	//Sending Output Buffer from GPU to CPU
	ret = clEnqueueReadBuffer(command_queue, img_Output, CL_TRUE, NULL, MaxBufferSize, dst, 0, NULL, NULL);

	for (int count = 0; count < 10; count++)
		std::cout << dst[count] << std::endl;
	//printf("%f", dst[0]);
	if (ret != CL_SUCCESS)
		return;
	return;
}

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
void bilinear_BayerRGGB2BGR(T* src, T* dst, const int width, const int height) {
	bool blue = true;
	int strideSrc = width;
	int strideDst = 3 * width;
	int vR, vB, vG;
	printf("parameters width %d, height %d, strideSrc %d, strideDst %d\n", width, height, strideSrc, strideDst);
	for (int j = 1; j<(height - 1); j++) {
		// start interpolation from the second pixel in each line
		if (blue) {  // contain B in bayer format
			for (int i = 1; i<(width - 1); i += 2) {
				T *cSrc = src + j * strideSrc + i;// locate the position of current pixel
				T *cDst = dst + j * strideDst + i * 3;
				//deal with the following pixel, where only B sample is available
				/* *
				* R G R
				* G|B|G
				* R G R
				* * */
				vG = (cSrc[-strideSrc] + cSrc[strideSrc] + cSrc[-1] + cSrc[1] + 2) >> 2;
				vR = (cSrc[-strideSrc - 1] + cSrc[-strideSrc + 1] + cSrc[strideSrc - 1] + cSrc[strideSrc + 1] + 2) >> 2;

				cDst[B] = cSrc[0]; // copy B
				cDst[G] = (T)vG;
				cDst[R] = (T)vR;
				if (i == 1 && j == 1)
					printf("first value output R G B %d %d %d\n", cDst[R], cDst[G], cDst[B]);
				//deal with the next horizontal pixel, where only G sample is available
				/* *
				* R G R G
				* G B|G|B
				* R G R G
				* * */
				cSrc += 1; cDst += 3;
				vB = (cSrc[-1] + cSrc[1] + 1) >> 1;
				vR = (cSrc[-strideSrc] + cSrc[strideSrc] + 1) >> 1;

				cDst[B] = (T)vB;
				cDst[G] = cSrc[0]; // copy G
				cDst[R] = (T)vR;
				if (i == 1 && j == 1)
					printf("first value output R G B %d %d %d\n", cDst[R], cDst[G], cDst[B]);
			}
		}
		else { // not contain B in bayer format
			for (int i = 1; i<(width - 1); i += 2) {
				T *cSrc = src + j * strideSrc + i;// locate the position of current pixel
				T *cDst = dst + j * strideDst + i * 3;
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
				cSrc += 1; cDst += 3;
				vG = (cSrc[-strideSrc] + cSrc[strideSrc] + cSrc[-1] + cSrc[1] + 2) >> 2;
				vB = (cSrc[-strideSrc - 1] + cSrc[-strideSrc + 1] + cSrc[strideSrc - 1] + cSrc[strideSrc + 1] + 2) >> 2;

				cDst[B] = (T)vB;
				cDst[G] = (T)vG;
				cDst[R] = cSrc[0]; // copy R
			}
		}
		//fill the first and last pixel of each row
		T *cDst = dst + j * strideDst;
		cDst[B] = cDst[3 + B];
		cDst[G] = cDst[3 + G];
		cDst[R] = cDst[3 + R];
		cDst[(width - 1) * 3 + B] = cDst[(width - 2) * 3 + B];
		cDst[(width - 1) * 3 + G] = cDst[(width - 2) * 3 + G];
		cDst[(width - 1) * 3 + R] = cDst[(width - 2) * 3 + R];
		blue = !blue;
	}
	// fill the first and last row of rgb
	for (int i = 0; i< strideDst; i++) {
		dst[i] = dst[i + strideDst];
		dst[(height - 1)*strideDst + i] = dst[(height - 2)*strideDst + i];
	}
}

#ifdef _WIN32
//struct timespec { long tv_sec; long tv_nsec; };    //header part
int clock_gettime(int, struct timespec *spec)      //C-file part
{
	__int64 wintime;
	GetSystemTimeAsFileTime((FILETIME*)&wintime);
	wintime -= 116444736000000000i64;  //1jan1601 to 1jan1970
	spec->tv_sec = wintime / 10000000i64;           //seconds
	spec->tv_nsec = wintime % 10000000i64 * 100;      //nano-seconds
	return 0;
}
#endif // _WIN32



int main(int argc, char *argv[])
{
	//BayerKernel();
	IplImage* bayerImg = 0;
	IplImage* debayerImg;
	int height, width, step, channels, depth;
	/*if (argc<2)
	{
	printf("Usage: opencv_demosaic <image-file-name>\n");
	exit(0);
	}*/
	// Load image   
	bayerImg = cvLoadImage("E:/Users/nerka/Onedrive/Uni Ordner/Multicore System/assignment4_src/demosaic/bayered_rainFruits438.png", -1);
	if (!bayerImg)
	{
		printf("Could not load image file: %s\n", argv[1]);
		exit(0);
	}
	// acquire image info  
	height = bayerImg->height;
	width = bayerImg->width;
	step = bayerImg->widthStep;
	channels = bayerImg->nChannels;
	depth = bayerImg->depth;
	//    printf("Processing a %dx%d image with %d channels bitdepth %d\n",height,width,channels, depth);
	// Convert from RGGB to RGB, i.e.,
	/* R G R G       // all R located at even rows and even columns
	* G B G B       // all B located at odd  rows and odd  columns
	* R G           // otherwise, are G points.
	* G B
	* -----
	*/
	// the original figure has channels in BGR order 
	debayerImg = cvCreateImage(cvSize(width, height), depth, 3);
	struct timespec ts_start, ts_end;
	double start, end;

	clock_gettime(CLOCK_REALTIME, &ts_start);
	BayerKernel((uchar *)bayerImg->imageData, (uchar *)debayerImg->imageData, width, height);
	/*if (depth == 8) {
	bilinear_BayerRGGB2BGR<uchar>((uchar *)bayerImg->imageData, (uchar *)debayerImg->imageData, width, height);
	}
	else {
	bilinear_BayerRGGB2BGR<ushort>((ushort *)bayerImg->imageData, (ushort *)debayerImg->imageData, width, height);
	}*/
	clock_gettime(CLOCK_REALTIME, &ts_end);
	start = (double)ts_start.tv_sec + (double)ts_start.tv_nsec / 1000000.0;
	end = (double)ts_end.tv_sec + (double)ts_end.tv_nsec / 1000000.0;
	printf("CPU bilinear filtering time %.3f ms \n", end - start);
	//	cvSaveImage("E:/Users/nerka/Onedrive/Uni Ordner/Multicore System/assignment4_src/images/lightHousedebayered.png", debayerImg);
	cvReleaseImage(&bayerImg);
	cvReleaseImage(&debayerImg);
	//    printf("height=%d  width=%d step=%d channels=%d\n",height,width,step,channels);
	return 0;
}

