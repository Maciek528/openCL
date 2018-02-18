// BayernOpenCL.cpp : Defines the entry point for the console application.
//
//#include "stdafx.h"

//OpenCV
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/ocl.hpp>

//OpenCL
#include <CL/cl.h>

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

#define errno_t int

#ifdef __unix
#define fopen_s(pFile,filename,mode) ((*(pFile))=fopen((filename),  (mode)))==NULL
#endif

#define CL_CHECK_ERROR(err) do{if (err) {printf("FATAL ERROR %d at " __FILE__ ":%d\n",err,__LINE__); exit(1); } } while(0)


void BayerKernel_ushort(ushort* src, ushort* out, const int width, const int height)
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


	ushort* dst1 = (ushort*)malloc(OutBufferSize);


	//Open kernel.cl file and store it in local string
	char *source_str = (char*)malloc(MAX_SOURCE_SIZE);
	size_t source_size;
	FILE *fp;
	errno_t errnum = fopen_s(&fp, "kernel_bayer_ushort.cl", "r");
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
	cl_kernel kernel = clCreateKernel(program, "bayer_ushort_filter", &ret);
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


void BayerKernel_uchar(uchar* src, uchar* out, const int width, const int height)
{
	//// Create a program from the kernel source
	cv::ocl::setUseOpenCL(true);
	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_platform_id *platforms = NULL;

	//int64_t MaxBufferSize = width * height * 2;
  int64_t MaxBufferSize = width * height;
  //int64_t range = MaxBufferSize / LoopCount >>1;
  int64_t range = MaxBufferSize / LoopCount;
  int64_t GrpSize = LoopCount;
	int64_t OutBufferSize =  MaxBufferSize * 3;

	std::cout << "OutBufferSize: " << OutBufferSize << std::endl;
  std::cout << "GrpSize: " << GrpSize << std::endl;

	uchar* dst1 = (uchar*)malloc(OutBufferSize);


	//Open kernel.cl file and store it in local string
	char *source_str = (char*)malloc(MAX_SOURCE_SIZE);
	size_t source_size;
	FILE *fp;
	errno_t errnum = fopen_s(&fp, "kernel_bayer_uchar.cl", "r");
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
	cl_kernel kernel = clCreateKernel(program, "bayer_uchar_filter", &ret);
	ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&img_Source);
	ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&img_Output1);
	ret = clSetKernelArg(kernel, 2, sizeof(cl_int), (void *)&GrpSize);
	ret = clSetKernelArg(kernel, 3, sizeof(cl_int), (void *)&width);
  //ret = clSetKernelArg(kernel, 4, sizeof(cl_int), (void *)&height);


	//Sending Input Buffer from CPU to GPU
	ret = clEnqueueWriteBuffer(command_queue, img_Source, CL_TRUE, NULL, MaxBufferSize, src,0,  NULL, NULL);

	//Execute the Kernel
	size_t global_item_size = range;
	size_t local_item_size = LocalItemCount;
  std::cout << "global_item_size: " << global_item_size << std::endl;
  std::cout << "local_item_size: " << local_item_size << std::endl;


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

void MHC_Kernel_uchar(uchar* src, uchar* out, const int width, const int height)
{
	//// Create a program from the kernel source
	cv::ocl::setUseOpenCL(true);
	cl_device_id device_id = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_platform_id *platforms = NULL;

	//int64_t MaxBufferSize = width * height * 2;
  int64_t MaxBufferSize = width * height;
  //int64_t range = MaxBufferSize / LoopCount >>1;
  int64_t range = MaxBufferSize / LoopCount;
  int64_t GrpSize = LoopCount;
	int64_t OutBufferSize =  MaxBufferSize * 3;

	std::cout << "OutBufferSize: " << OutBufferSize << std::endl;
  std::cout << "GrpSize: " << GrpSize << std::endl;

	uchar* dst1 = (uchar*)malloc(OutBufferSize);


	//Open kernel.cl file and store it in local string
	char *source_str = (char*)malloc(MAX_SOURCE_SIZE);
	size_t source_size;
	FILE *fp;
	errno_t errnum = fopen_s(&fp, "kernel_local.cl", "r");
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
  if(ret != CL_SUCCESS)
    std::cout <<  "clGetPlatformIDs() failed with error: " << ret << std::endl;

	platforms = (cl_platform_id*)malloc(ret_num_platforms * sizeof(cl_platform_id));

  ret = clGetPlatformIDs(ret_num_platforms, platforms, NULL);
  if(ret != CL_SUCCESS)
    std::cout <<  "clGetPlatformIDs() failed with error: " << ret << std::endl;

  ret = clGetDeviceIDs(platforms[0], CL_DEVICE_TYPE_ALL, 1, &device_id, &ret_num_devices);
  if(ret != CL_SUCCESS)
    std::cout <<  "clGetDeviceIDs() failed with error: " << ret << std::endl;

  cl_context context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);
  if(ret != CL_SUCCESS)
    std::cout <<  "clCreateContext() failed with error: " << ret << std::endl;

  cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
  if(ret != CL_SUCCESS)
    std::cout <<  "clCreateCommandQueue() failed with error: " << ret << std::endl;

  // Create a program from the kernel source 	and Build the program
	cl_program program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&ReadingSize, &ret);
  if(ret != CL_SUCCESS)
    std::cout <<  "clCreateProgramWithSource() failed with error: " << ret << std::endl;

  ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
  if (ret != CL_SUCCESS)
  {
    std::cout <<  "clBuildProgram() failed with error: " << ret << std::endl;
    cl_build_status build_status;
    CL_CHECK_ERROR(clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_STATUS, sizeof(cl_build_status), &build_status, NULL));
    if (build_status == CL_SUCCESS)
    {
      std::cout << "build successful" << std::endl;
    }
    else
    {
      char *build_log;
      size_t ret_val_size;
      CL_CHECK_ERROR(clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, 0, NULL, &ret_val_size));
      build_log = new char[ret_val_size+1];
      CL_CHECK_ERROR(clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, ret_val_size, build_log, NULL));
      // to be carefully, terminate with \0
      // there's no information in the reference whether the string is 0 terminated or not
      build_log[ret_val_size] = '\0';
      std::cout << "BUILD LOG: '" << "filepath" << "'" << std::endl;
      std::cout << build_log << std::endl;
      delete[] build_log;
    }
  }


	// Allocate Buffer in GPU
	cl_mem img_Source = clCreateBuffer(context, CL_MEM_READ_ONLY, MaxBufferSize, NULL, &ret);
  if(ret != CL_SUCCESS)
    std::cout <<  "clCreateBuffer() input failed with error: " << ret << std::endl;
	cl_mem img_Output1 = clCreateBuffer(context, CL_MEM_WRITE_ONLY, OutBufferSize, NULL, &ret);//clCreateBuffer(context, CL_MEM_WRITE_ONLY, MaxBufferSize, out, &ret);
  if(ret != CL_SUCCESS)
  {
    std::cout <<  "clCreateBuffer() output failed with error: " << ret << std::endl;
  }
  auto start = std::chrono::high_resolution_clock::now();
	//Create the Kernel to call the function bayer_filter
	cl_kernel kernel = clCreateKernel(program, "mhc_kernel_uchar", &ret);
  if(ret != CL_SUCCESS)
    std::cout <<  "clCreateKernel() failed with error: " << ret << std::endl;
	ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&img_Source);
  if(ret != CL_SUCCESS)
    std::cout <<  "clSetKernelArg() 0 failed with error: " << ret << std::endl;
	ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&img_Output1);
  if(ret != CL_SUCCESS)
    std::cout <<  "clSetKernelArg() 1 failed with error: " << ret << std::endl;
	ret = clSetKernelArg(kernel, 2, sizeof(cl_int), (void *)&GrpSize);
  if(ret != CL_SUCCESS)
    std::cout <<  "clSetKernelArg() 2 failed with error: " << ret << std::endl;
	ret = clSetKernelArg(kernel, 3, sizeof(cl_int), (void *)&width);
  if(ret != CL_SUCCESS)
    std::cout <<  "clSetKernelArg() 3 failed with error: " << ret << std::endl;

  //ret = clSetKernelArg(kernel, 4, sizeof(cl_int), (void *)&height);


	//Sending Input Buffer from CPU to GPU
	ret = clEnqueueWriteBuffer(command_queue, img_Source, CL_TRUE, NULL, MaxBufferSize, src,0,  NULL, NULL);
  if(ret != CL_SUCCESS)
    std::cout <<  "clEnqueueWriteBuffer() failed with error: " << ret << std::endl;

	//Execute the Kernel
	size_t global_item_size = range;
	size_t local_item_size = LocalItemCount;
  std::cout << "global_item_size: " << global_item_size << std::endl;
  std::cout << "local_item_size: " << local_item_size << std::endl;


	ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL,&global_item_size, &local_item_size, 0, NULL, NULL);
  if(ret != CL_SUCCESS)
    std::cout <<  "clEnqueueNDRangeKernel() failed with error: " << ret << std::endl;

	//Sending Output Buffer from GPU to CPU
	ret = clEnqueueReadBuffer(command_queue, img_Output1, CL_TRUE, NULL, OutBufferSize, out, 0, NULL, NULL);
  if(ret != CL_SUCCESS)
    std::cout <<  "clEnqueueReadBuffer() failed with error: " << ret << std::endl;

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
	height = bayerImg->height;
	width = bayerImg->width;
	step = bayerImg->widthStep;
	channels = bayerImg->nChannels;
	depth = bayerImg->depth;

  std::cout << "Image (width x height @ depth): " << width << " x " << height << " @ " << depth << std::endl;



	debayerImg = cvCreateImage(cvSize(width, height), depth, 3);

	//BayerKernel_ushort((ushort*)bayerImg->imageData, (ushort *)debayerImg->imageData, width, height);
  //BayerKernel_uchar((uchar*)bayerImg->imageData, (uchar*)debayerImg->imageData, width, height);
  MHC_Kernel_uchar((uchar*)bayerImg->imageData, (uchar*)debayerImg->imageData, width, height);

	cvSaveImage("debayered.png", debayerImg);
	cvReleaseImage(&bayerImg);
	cvReleaseImage(&debayerImg);
	return 0;

}
