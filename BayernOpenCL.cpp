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
#define LocalItemCount 256
#define LoopCount 1

void BayerKernel(ushort* src, ushort* out, const int width, const int height)
{
	//// Create a program from the kernel source
	cv::ocl::setUseOpenCL(true);
	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_platform_id *platforms = NULL;

	int64_t MaxBufferSize = width * height * 2;
	int64_t range = MaxBufferSize / LoopCount >>1;
	int64_t GrpSize = LoopCount;
	int64_t OutBufferSize =  MaxBufferSize * 3;

	

	std::cout << OutBufferSize << std::endl;

	ushort* dst1 = (ushort*)malloc(OutBufferSize);


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
	cl_mem img_Output1 = clCreateBuffer(context, CL_MEM_WRITE_ONLY, OutBufferSize, NULL, &ret);//clCreateBuffer(context, CL_MEM_WRITE_ONLY, MaxBufferSize, out, &ret);

	auto start = std::chrono::high_resolution_clock::now();
	//Create the Kernel to call the function bayer_filter
	cl_kernel kernel = clCreateKernel(program, "bayer_filter", &ret);
	ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&img_Source);
	ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&img_Output1);
	ret = clSetKernelArg(kernel, 2, sizeof(cl_int), (void *)&GrpSize);
	ret = clSetKernelArg(kernel, 3, sizeof(cl_int), (void *)&width);

	
	//Sending Input Buffer from CPU to GPU
	ret = clEnqueueWriteBuffer(command_queue, img_Source, CL_TRUE, NULL, MaxBufferSize, src,0,  NULL, NULL);

	//Execute the Kernel
	size_t global_item_size = range;
	size_t local_item_size = LocalItemCount;
	
	ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL,&global_item_size, &local_item_size, 0, NULL, NULL);
	
	//Sending Output Buffer from GPU to CPU
	ret = clEnqueueReadBuffer(command_queue, img_Output1, CL_TRUE, NULL, OutBufferSize, out, 0, NULL, NULL);

	auto end = std::chrono::high_resolution_clock::now();
	double totaltime = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
	printf("Elapsed time is: %.3f ms", totaltime/1000000.0);
	
	
	if (ret != CL_SUCCESS)
	{
		std::cout << "Error!!!" << std::endl;
	}

	if (dst1)delete dst1;
	if (kernel)clReleaseKernel(kernel);
	if (program)clReleaseProgram(program);
	if (command_queue)clReleaseCommandQueue(command_queue);
	if (context)clReleaseContext(context);
	if (img_Source)clReleaseMemObject(img_Source);
	if (img_Output1)clReleaseMemObject(img_Output1);
		
	return;
}




int main(int argc, char *argv[])

{

	IplImage* bayerImg = 0;
	IplImage* debayerImg;
	int height, width, step, channels, depth;

	if (argc<2)
	{
		printf("Usage: opencv_demosaic <image-file-name>\n");
		exit(0);
	}

	// Load image   
	bayerImg = cvLoadImage(argv[1], -1);
	if (!bayerImg)
	{
		printf("Could not load image file: %s\n", argv[1]);
		exit(0);
	}
	// acquire image info  
	eight = bayerImg->height;
	width = bayerImg->width;
	step = bayerImg->widthStep;
	channels = bayerImg->nChannels;
	depth = bayerImg->depth;



	debayerImg = cvCreateImage(cvSize(width, height), depth, 3);

	BayerKernel((ushort*)bayerImg->imageData, (ushort *)debayerImg->imageData, width, height);


	cvSaveImage("debayered.png", debayerImg)
	cvReleaseImage(&bayerImg);
	cvReleaseImage(&debayerImg);
	return 0;

}




