int normal(int val)
{
	int max = 255;
	int min = 0;
	/*if (val > max)
		return max;
	if (val < min)
		return min;
	
	return val;*/
	int bufVal= 0;
	if (val > min)
		bufVal = val;
	else
		bufVal = min;

	if (bufVal > max)
		bufVal = max;

	return bufVal;
};


__kernel void mhc_kernel_uchar(__global uchar* a, __global uchar* c, const int GrpCount, const int width)
{
	
	int GLidx = get_global_id(0);

	int range = get_global_size(0);
	int height = range * GrpCount;


	__local uchar sharedData[10];

	for (int index = 0; index < GrpCount; index++)
	{
		int Gidx = (index * range + GLidx);


		int Red, Green, Blue;

		int R = (Gidx / width);		// R = index of Row, Max value is (heigth - 1)
		int C = Gidx - (R * width);		// C = index of Column, Max value is  (width  - 1)

		__local uchar pixel[5000];
		pixel[(get_local_id(0)+1)*width*2] = a[Gidx];
		/*__local uchar Output_pixel[width * 3];
		Output_pixel[Gidx] = c[Gidx * 3];*/

		//__local uchar* pixel;// = a + Gidx;
		//pixel = a + Gidx;

		//global uchar* pixel = a + Gidx;
		global uchar* Output_pixel = c + Gidx * 3;

		barrier(CLK_LOCAL_MEM_FENCE);

		if (/*get_local_id(0) < 500*/true)
		{
			if (R % 2 == 0 && C % 2 == 0)
			{ // RED PIXEL

				Green = ((2 * (pixel[-width] + pixel[-1] + pixel[1] + pixel[width])) +
					(4 * pixel[0])
					- pixel[-2 * width] - pixel[-2] - pixel[2] - pixel[2 * width]) >> 3;
				Blue = ((4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) +
					(12 * pixel[0])
					- 3 * pixel[-2 * width] - 3 * pixel[-2] - 3 * pixel[2] - 3 * pixel[2 * width]) >> 4;
				Red = pixel[0];

				Green = normal(Green);
				Blue = normal(Blue);

				// set some dummy for now
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G|R|G
				  * G B G B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = a[R*width+C];

				  //Red 	= sharedData[2][2];
				  //Blue 	= (12*sharedData[2][2]-3*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4]) + 4*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3])) >> 4;
				  //Green = ( 4*sharedData[2][2]+2*(sharedData[1][2]   + sharedData[3][2]   + sharedData[2][1] + sharedData[2][3]) - 1*(sharedData[0][2] + sharedData[4][2]  + sharedData[2][0] + sharedData[2][4])) >> 3;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (12 * pixel[0] - 3 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2]) + 4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) >> 4;
				  //Green = (4 * pixel[0] + 2 * (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) - 1 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2])) >> 3;
				  //Red = pixel[0];   // copy R


				}
			}
			else if (R % 2 == 1 && C % 2 == 1)
			{ // BLUE PIXEL


				Green = ((2 * (pixel[-width] + pixel[-1] + pixel[1] + pixel[width])) +
					(4 * pixel[0])
					- pixel[-2 * width] - pixel[-2] - pixel[2] - pixel[2 * width]) >> 3;
				Red = ((4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) +
					(12 * pixel[0])
					- 3 * pixel[-2 * width] - 3 * pixel[-2] - 3 * pixel[2] - 3 * pixel[2 * width]) >> 4;
				Blue = pixel[0];

				Red = normal(Red);
				Green = normal(Green);

				// set some dummy for now
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R G
				  * G B G|B|
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Red 	= (12*sharedData[2][2]-3*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4]) + 4*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3])) >> 4;
				  //Blue 	= sharedData[2][2];
				  //Green = (4*sharedData[2][2]+2*(sharedData[1][2] + sharedData[3][2] + sharedData[2][1] + sharedData[2][3]) - 1*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4])) >> 3;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Green = (4 * pixel[0] + 2 * (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) - 1 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2])) >> 3;
				  //Red = (12 * pixel[0] - 3 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2]) + 4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) >> 4;
				  //Blue = pixel[0]; // copy B



				}

			}
			else if (R % 2 == 1 && C % 2 == 0)
			{ // GREEN PIXEL IN BLUE ROW

			  // set some dummy for now

				Blue = (10 * pixel[0] +
					8 * (pixel[-1] + pixel[1])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
					+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				Red = (10 * pixel[0] +
					8 * (pixel[-width] + pixel[width])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width])
					+ (pixel[-2] + pixel[2])) >> 4;
				Green = pixel[0]; // copy G

				Blue = normal(Blue);
				Red = normal(Red);
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R G
				  * G B|G|B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Blue 	=  (10*sharedData[2][2] + 8*(sharedData[2][1] + sharedData[2][3])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[2][0] + sharedData[2][4]) + (sharedData[0][2] + sharedData[4][2])) >> 4;
				  //Green = sharedData[2][2];
				  //Red 	=  (10*sharedData[2][2] + 8*(sharedData[1][2]+sharedData[3][2])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[0][2] + sharedData[4][2]) + (sharedData[2][0] + sharedData[2][4])) >> 4;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (10 * pixel[0] + 
				  //		8 * (pixel[-1] + pixel[1]) 
				  //		- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
				  //		+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				  //Red = (10 * pixel[0] +
				  //		8 * (pixel[-width] + pixel[width]) 
				  //		- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width]) 
				  //		+ (pixel[-2] + pixel[2])) >> 4;
				  //Green = pixel[0]; // copy G
				}
			}
			else
			{ // GREEN PIXEL IN RED ROW
			  // set some dummy for now

				Red = (10 * pixel[0] +
					8 * (pixel[-1] + pixel[1])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
					+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				Blue = (10 * pixel[0] +
					8 * (pixel[-width] + pixel[width])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width])
					+ (pixel[-2] + pixel[2])) >> 4;
				Green = pixel[0]; // copy G

				Blue = normal(Blue);
				Red = normal(Red);
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R|G|
				  * G B G B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Blue 	=	(10*sharedData[2][2] + 8*(sharedData[1][2]+sharedData[3][2])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[2][1] + sharedData[2][3] + sharedData[0][2] + sharedData[4][2]) + (sharedData[2][0] + sharedData[2][4])) >> 4;
				  //Green = sharedData[2][2];
				  //Red 	= (10*sharedData[2][2] + 8*(sharedData[2][1]+sharedData[2][3])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[2][0] + sharedData[2][4]) + (sharedData[0][2] + sharedData[4][2])) >> 4;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (10 * pixel[0] + 8 * (pixel[-width] + pixel[width]) - 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width]) + (pixel[-2] + pixel[2])) >> 4;
				  //Red = (10 * pixel[0] + 8 * (pixel[-1] + pixel[1]) - 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2]) + (pixel[-2 * width] + pixel[2 * width])) >> 4;
				  //Green = pixel[0];  // copy G


				}
			}

		}
		else
		{
			if (R % 2 == 0 && C % 2 == 0)
			{ // RED PIXEL

				Green = ((2 * (pixel[-width] + pixel[-1] + pixel[1] + pixel[width])) +
					(4 * pixel[0])
					- pixel[-2 * width] - pixel[-2] - pixel[2] - pixel[2 * width]) >> 3;
				Blue = ((4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) +
					(12 * pixel[0])
					- 3 * pixel[-2 * width] - 3 * pixel[-2] - 3 * pixel[2] - 3 * pixel[2 * width]) >> 4;
				Red = pixel[0];

				// set some dummy for now
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G|R|G
				  * G B G B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = a[R*width+C];

				  //Red 	= sharedData[2][2];
				  //Blue 	= (12*sharedData[2][2]-3*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4]) + 4*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3])) >> 4;
				  //Green = ( 4*sharedData[2][2]+2*(sharedData[1][2]   + sharedData[3][2]   + sharedData[2][1] + sharedData[2][3]) - 1*(sharedData[0][2] + sharedData[4][2]  + sharedData[2][0] + sharedData[2][4])) >> 3;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (12 * pixel[0] - 3 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2]) + 4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) >> 4;
				  //Green = (4 * pixel[0] + 2 * (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) - 1 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2])) >> 3;
				  //Red = pixel[0];   // copy R


				}
			}
			else if (R % 2 == 1 && C % 2 == 1)
			{ // BLUE PIXEL


				Green = ((2 * (pixel[-width] + pixel[-1] + pixel[1] + pixel[width])) +
					(4 * pixel[0])
					- pixel[-2 * width] - pixel[-2] - pixel[2] - pixel[2 * width]) >> 3;
				Red = ((4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) +
					(12 * pixel[0])
					- 3 * pixel[-2 * width] - 3 * pixel[-2] - 3 * pixel[2] - 3 * pixel[2 * width]) >> 4;
				Blue = pixel[0];

				// set some dummy for now
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R G
				  * G B G|B|
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Red 	= (12*sharedData[2][2]-3*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4]) + 4*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3])) >> 4;
				  //Blue 	= sharedData[2][2];
				  //Green = (4*sharedData[2][2]+2*(sharedData[1][2] + sharedData[3][2] + sharedData[2][1] + sharedData[2][3]) - 1*(sharedData[0][2] + sharedData[4][2] + sharedData[2][0] + sharedData[2][4])) >> 3;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Green = (4 * pixel[0] + 2 * (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) - 1 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2])) >> 3;
				  //Red = (12 * pixel[0] - 3 * (pixel[-2 * width] + pixel[2 * width] + pixel[-2] + pixel[2]) + 4 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1])) >> 4;
				  //Blue = pixel[0]; // copy B



				}

			}
			else if (R % 2 == 1 && C % 2 == 0)
			{ // GREEN PIXEL IN BLUE ROW

			  // set some dummy for now

				Blue = (10 * pixel[0] +
					8 * (pixel[-1] + pixel[1])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
					+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				Red = (10 * pixel[0] +
					8 * (pixel[-width] + pixel[width])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width])
					+ (pixel[-2] + pixel[2])) >> 4;
				Green = pixel[0]; // copy G
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R G
				  * G B|G|B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Blue 	=  (10*sharedData[2][2] + 8*(sharedData[2][1] + sharedData[2][3])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[2][0] + sharedData[2][4]) + (sharedData[0][2] + sharedData[4][2])) >> 4;
				  //Green = sharedData[2][2];
				  //Red 	=  (10*sharedData[2][2] + 8*(sharedData[1][2]+sharedData[3][2])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[0][2] + sharedData[4][2]) + (sharedData[2][0] + sharedData[2][4])) >> 4;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (10 * pixel[0] + 
				  //		8 * (pixel[-1] + pixel[1]) 
				  //		- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
				  //		+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				  //Red = (10 * pixel[0] +
				  //		8 * (pixel[-width] + pixel[width]) 
				  //		- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width]) 
				  //		+ (pixel[-2] + pixel[2])) >> 4;
				  //Green = pixel[0]; // copy G
				}
			}
			else
			{ // GREEN PIXEL IN RED ROW
			  // set some dummy for now

				Red = (10 * pixel[0] +
					8 * (pixel[-1] + pixel[1])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2])
					+ (pixel[-2 * width] + pixel[2 * width])) >> 4;
				Blue = (10 * pixel[0] +
					8 * (pixel[-width] + pixel[width])
					- 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width])
					+ (pixel[-2] + pixel[2])) >> 4;
				Green = pixel[0]; // copy G
				if (R == 0 || R == 1)
				{ // two first rows

				}
				else if (R == height - 1 || R == height - 2)
				{ // last two rows

				}
				else if (C == 0 || C == 1)
				{ // first two columns

				}
				else if (C == width - 1 || C == width - 2)
				{ // last two columns

				}
				else
				{ // non-border part of image
				  /* *
				  * R G R G
				  * G B G B
				  * R G R|G|
				  * G B G B
				  * * */
				  //Tidy = get_local_id(1);
				  //Tidx = get_local_id(0);
				  //sharedData[Tidy][Tidx] = pixel[R*width+C];

				  //Blue 	=	(10*sharedData[2][2] + 8*(sharedData[1][2]+sharedData[3][2])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[2][1] + sharedData[2][3] + sharedData[0][2] + sharedData[4][2]) + (sharedData[2][0] + sharedData[2][4])) >> 4;
				  //Green = sharedData[2][2];
				  //Red 	= (10*sharedData[2][2] + 8*(sharedData[2][1]+sharedData[2][3])-2*(sharedData[1][1] + sharedData[1][3] + sharedData[3][1] + sharedData[3][3] + sharedData[2][0] + sharedData[2][4]) + (sharedData[0][2] + sharedData[4][2])) >> 4;
				  //barrier(CLK_LOCAL_MEM_FENCE);

				  //Blue = (10 * pixel[0] + 8 * (pixel[-width] + pixel[width]) - 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2 * width] + pixel[2 * width]) + (pixel[-2] + pixel[2])) >> 4;
				  //Red = (10 * pixel[0] + 8 * (pixel[-1] + pixel[1]) - 2 * (pixel[-width - 1] + pixel[-width + 1] + pixel[width - 1] + pixel[width + 1] + pixel[-2] + pixel[2]) + (pixel[-2 * width] + pixel[2 * width])) >> 4;
				  //Green = pixel[0];  // copy G


				}
			}
		}
		

		// bound the data between 0 and 255
		//char maxVal = 255;
		//char minVal = 0;

		// if 			(Blue > maxVal){	Output_Green[0] = maxVal;		}
		// else if (Blue < minVal){	Output_Green[0] = minVal;		}
		// else									 {	Output_Green[0] = Blue;			}
		//
		// if 			(Green > maxVal){	Output_Green[1] = maxVal;	}
		// else if (Green < minVal){	Output_Green[1] = minVal; }
		// else										{	Output_Green[1] = Green;	}
		//
		// if 			(Red > maxVal){	Output_Green[2] = maxVal;	}
		// else if (Red < minVal){	Output_Green[2] = minVal;	}
		// else									{	Output_Green[2] = Red;    }

		Output_pixel[0] = Blue;
		Output_pixel[1] = Green;
		Output_pixel[2] = Red;

	/*	if (Red = 36 && Green == 26 && Blue == 253)
			printf("%d %d \n", R, C);*/
	}


}