// BayernOpenCL.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

//OpenCV 
#include <opencv\cv.h>
#include "opencv\highgui.h"
#include "opencv2\imgproc.hpp"
#include "opencv2\core.hpp"
#include "opencv2\core\ocl.hpp"

//OpenCL
#include <CL\cl.h>

//C++ Standart
#include <chrono>
#include <time.h>
#include <stdlib.h>  
#include <stdio.h>  
#include <math.h>
#include <iostream>


using namespace cv;

#define MAX_SOURCE_SIZE (0x100000)
#define MAXGroupCount 1

void BayerKernel(uchar* src, uchar* out, const int width, const int height)
{
	//// Create a program from the kernel source
	cv::ocl::setUseOpenCL(true);
	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_platform_id *platforms = NULL;

	int MaxBufferSize = width * height;
	int range = MaxBufferSize / MAXGroupCount;
	int GrpSize = MAXGroupCount;
	int OutBufferSize = sizeof(uchar) * MaxBufferSize * 3;

	uchar* dst = (uchar*)malloc(OutBufferSize);

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
	cl_mem img_Output = clCreateBuffer(context, CL_MEM_WRITE_ONLY, OutBufferSize, NULL, &ret);//clCreateBuffer(context, CL_MEM_WRITE_ONLY, MaxBufferSize, out, &ret);


	auto start = std::chrono::high_resolution_clock::now();
	//Create the Kernel to call the function bayer_filter
	cl_kernel kernel = clCreateKernel(program, "bayer_filter", &ret);
	ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&img_Source);
	ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&img_Output);
	ret = clSetKernelArg(kernel, 2, sizeof(cl_int), (void *)&GrpSize);
	ret = clSetKernelArg(kernel, 3, sizeof(cl_int), (void *)&width);

	
	//Sending Input Buffer from CPU to GPU
	ret = clEnqueueWriteBuffer(command_queue, img_Source, CL_TRUE, NULL, MaxBufferSize, src,0,  NULL, NULL);

	//Execute the Kernel
	size_t global_item_size = range;
	size_t local_item_size = 256;
	
	ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL,&global_item_size, &local_item_size, 0, NULL, NULL);
	
	//Sending Output Buffer from GPU to CPU
	ret = clEnqueueReadBuffer(command_queue, img_Output, CL_TRUE, NULL, OutBufferSize, dst, 0, NULL, NULL);

	auto end = std::chrono::high_resolution_clock::now();
	double totaltime = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
	printf("Elapsed time is: %.3f ms", totaltime/1000000.0);
	
	for (int in = 0; in < OutBufferSize; in++)
	{
		out[in] = dst[in];
	}
	
	if (ret != CL_SUCCESS)
	{
		std::cout << "Error!!!" << std::endl;
	}

	if (dst)delete dst;
	if (kernel)clReleaseKernel(kernel);
	if (program)clReleaseProgram(program);
	if (command_queue)clReleaseCommandQueue(command_queue);
	if (context)clReleaseContext(context);
	if (img_Source)clReleaseMemObject(img_Source);
	if (img_Output)clReleaseMemObject(img_Output);
		
	return;
}




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
	bayerImg = cvLoadImage("E:/Users/nerka/Onedrive/Uni Ordner/Multicore System/assignment4_src/demosaic/bayered_rainFruits438.png", 0);
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
	
	BayerKernel((uchar*)bayerImg->imageData, (uchar *)debayerImg->imageData, width, height);



	cvSaveImage("E:/Users/nerka/Onedrive/Uni Ordner/Multicore System/assignment4_src/demosaic/test.png", debayerImg);
	cvReleaseImage(&bayerImg);
	cvReleaseImage(&debayerImg);
	return 0;
}




