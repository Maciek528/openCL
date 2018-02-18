int normal(int val)
{
	int max = 255;
	int min = 0;
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
	int LOidx = get_local_id(0) + width * 2;

	int range = get_global_size(0);
	int height = range * GrpCount / width;


	for (int index = 0; index < GrpCount; index++)
	{
		int Gidx = (index * range + GLidx);

		__local int Red, Green, Blue;

		int R = (Gidx / width);		// R = index of Row, Max value is (heigth - 1)
		int C = Gidx - (R * width);		// C = index of Column, Max value is  (width  - 1)


		__local uchar pLocal[5000];
		pLocal[LOidx - (width * 2)] = a[Gidx - width * 2 ];	//Local Size 1024 - 512  - 256
		pLocal[LOidx - (width * 2 - width/2)] = a[Gidx - (width * 2 - width/2)]; //Local Size  256
		pLocal[LOidx - (width)] = a[Gidx - width];  //Local Size 512  - 256
		pLocal[LOidx - (width/2)] = a[Gidx - width/2]; //Local Size 256
		pLocal[LOidx] = a[Gidx]; //Local Size 1024 - 512  - 256
		pLocal[LOidx + (width / 2)] = a[Gidx + width / 2]; //Local Size  256
		pLocal[LOidx + (width)] = a[Gidx + width]; //Local Size 512  - 256
		pLocal[LOidx + (width * 2 - width / 2)] = a[Gidx + (width * 2 - width / 2)];  //Local Size  256
		pLocal[LOidx + (width * 2) ] =  a[Gidx + width * 2]; //Local Size 1024 - 512  - 256

		barrier(CLK_LOCAL_MEM_FENCE);


		if (R % 2 == 0 && C % 2 == 0)
		{ // RED PIXEL

			if( R != 0 && R != 1 && R != (height-2) 	&& R != (height-1) &&
					C != 0 && C != 1 && C != (width -2) 	&& C != (width -1) )
			{
				Green 	= ((2 * (pLocal[LOidx -width] + pLocal[LOidx-1] + pLocal[LOidx+1] + pLocal[LOidx + width])) +
									(4 * pLocal[LOidx])
									- pLocal[LOidx -2 * width] - pLocal[LOidx -2] - pLocal[LOidx+2] - pLocal[LOidx + 2 * width]) >> 3;
				Blue 		= ((4 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx +width + 1])) +
									(12 * pLocal[LOidx])
									- 3 * pLocal[LOidx -2 * width] - 3 * pLocal[LOidx-2] - 3 * pLocal[LOidx+2] - 3 * pLocal[LOidx + 2 * width]) >> 4;
				Red 		= pLocal[LOidx];

				Green 	= normal(Green);
				Blue 		= normal(Blue);

				if(R == 2)
				{
					c[(Gidx - width) * 3] 		= c[(Gidx - 2 * width) * 3] 		= Blue;
					c[(Gidx - width) * 3 + 1] = c[(Gidx - 2 * width) * 3 + 1] = Green;
					c[(Gidx - width) * 3 + 2] = c[(Gidx - 2 * width) * 3 + 2] =  Red;
				}

				if(C == 2)
				{
					c[(Gidx - 1) * 3] 		= c[(Gidx - 2) * 3] 		= Blue;
					c[(Gidx - 1) * 3 + 1] = c[(Gidx - 2) * 3 + 1] = Green;
					c[(Gidx - 1) * 3 + 2] = c[(Gidx - 2) * 3 + 2] = Red;
				}

				if( R == 2 && C == 2) // fill the upper left corner
				{
					c[(Gidx - width - 1) * 3] 		= c[(Gidx - 2 * width - 1) * 3] 		= c[(Gidx - width - 2) * 3] 		= c[(Gidx - 2 * width - 2) * 3] 		= Blue;
					c[(Gidx - width - 1) * 3 + 1] = c[(Gidx - 2 * width - 1) * 3 + 1] = c[(Gidx - width - 2) * 3 + 1] = c[(Gidx - 2 * width - 2) * 3 + 1] = Green;
					c[(Gidx - width - 1) * 3 + 2] = c[(Gidx - 2 * width - 1) * 3 + 2] = c[(Gidx - width - 2) * 3 + 2] = c[(Gidx - 2 * width - 2) * 3 + 2] = Red;
				}

				if(C == width - 3)
				{
					c[(Gidx + 1) * 3] 		= c[(Gidx + 2) * 3] 		= Blue;
					c[(Gidx + 1) * 3 + 1] = c[(Gidx + 2) * 3 + 1] = Green;
					c[(Gidx + 1) * 3 + 2] = c[(Gidx + 2) * 3 + 2] = Red;
				}

				c[Gidx * 3] 		= Blue;
				c[Gidx * 3 + 1] = Green;
				c[Gidx * 3 + 2] = Red;

			}


		}
		else if (R % 2 == 1 && C % 2 == 1)
		{ // BLUE PIXEL

			if( R != 0 && R != 1 && R != (height-2) 	&& R != (height-1) &&
					C != 0 && C != 1 && C != (width -2) 	&& C != (width -1) )
			{
				Green = ((2 * (pLocal[LOidx - width] + pLocal[LOidx - 1] + pLocal[LOidx + 1] + pLocal[LOidx + width])) +
							(4 * pLocal[LOidx])
							- pLocal[LOidx - 2 * width] - pLocal[LOidx - 2] - pLocal[LOidx + 2] - pLocal[LOidx + 2 * width]) >> 3;
				Red = ((4 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1])) +
							(12 * pLocal[LOidx])
							- 3 * pLocal[LOidx - 2 * width] - 3 * pLocal[LOidx - 2] - 3 * pLocal[LOidx + 2] - 3 * pLocal[LOidx + 2 * width]) >> 4;
				Blue = pLocal[LOidx];

				Red = normal(Red);
				Green = normal(Green);

				if(R == height - 3)
				{
					c[(Gidx + width) * 3] 		= c[(Gidx + 2 * width) * 3] 		= Blue;
					c[(Gidx + width) * 3 + 1] = c[(Gidx + 2 * width) * 3 + 1] = Green;
					c[(Gidx + width) * 3 + 2] = c[(Gidx + 2 * width) * 3 + 2]	= Red;
				}

				if(C == 2)
				{
					c[(Gidx - 1) * 3] 		= c[(Gidx - 2) * 3] 		= Blue;
					c[(Gidx - 1) * 3 + 1] = c[(Gidx - 2) * 3 + 1] = Green;
					c[(Gidx - 1) * 3 + 2] = c[(Gidx - 2) * 3 + 2] = Red;
				}

				if(C == width - 3)
				{
					c[(Gidx + 1) * 3] 		= c[(Gidx + 2) * 3] 		= Blue;
					c[(Gidx + 1) * 3 + 1] = c[(Gidx + 2) * 3 + 1] = Green;
					c[(Gidx + 1) * 3 + 2] = c[(Gidx + 2) * 3 + 2] = Red;
				}

				if( R == height - 3 && C == width - 3 ) // fill the bottom right corner
				{
					c[(Gidx + width + 1) * 3] 		= c[(Gidx + 2 * width + 1) * 3] 		= c[(Gidx + width + 2) * 3] 		= c[(Gidx + 2 * width + 2) * 3] 		= Blue;
					c[(Gidx + width + 1) * 3 + 1] = c[(Gidx + 2 * width + 1) * 3 + 1] = c[(Gidx + width + 2) * 3 + 1] = c[(Gidx + 2 * width + 2) * 3 + 1] = Green;
					c[(Gidx + width + 1) * 3 + 2] = c[(Gidx + 2 * width + 1) * 3 + 2] = c[(Gidx + width + 2) * 3 + 2] = c[(Gidx + 2 * width + 2) * 3 + 2] = Red;
				}

				c[Gidx * 3] 		= Blue;
				c[Gidx * 3 + 1] = Green;
				c[Gidx * 3 + 2] = Red;

			}



		}
		else if (R % 2 == 1 && C % 2 == 0)
		{ // GREEN PIXEL IN BLUE ROW

			// set some dummy for now
			if( R != 0 && R != 1 && R != (height-2) 	&& R != (height-1) &&
					C != 0 && C != 1 && C != (width -2) 	&& C != (width -1) )
			{
				Blue 	= (10 * pLocal[LOidx] +
								8 * (pLocal[LOidx-1] + pLocal[LOidx +1])
								- 2 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx -2] + pLocal[LOidx+2])
								+ (pLocal[LOidx -(2 * width)] + pLocal[LOidx + (2 * width)])) >> 4;
				Red 	= (10 * pLocal[LOidx] +
								8 * (pLocal[LOidx -width] + pLocal[LOidx + width])
								- 2 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx -2 * width] + pLocal[LOidx +2 * width])
								+ (pLocal[LOidx -2] + pLocal[LOidx+2])) >> 4;
				Green = pLocal[LOidx]; // copy G

				Blue = normal(Blue);
				Red = normal(Red);

				if(R == height - 3)
				{
					c[(Gidx + width) * 3] 		= c[(Gidx + 2 * width) * 3] 		= Blue;
					c[(Gidx + width) * 3 + 1] = c[(Gidx + 2 * width) * 3 + 1] = Green;
					c[(Gidx + width) * 3 + 2] = c[(Gidx + 2 * width) * 3 + 2]	= Red;
				}

				if(C == 2)
				{
					c[(Gidx - 1) * 3] 		= c[(Gidx - 2) * 3] 		= Blue;
					c[(Gidx - 1) * 3 + 1] = c[(Gidx - 2) * 3 + 1] = Green;
					c[(Gidx - 1) * 3 + 2] = c[(Gidx - 2) * 3 + 2] = Red;
				}

				if(C == width - 3)
				{
					c[(Gidx + 1) * 3] 		= c[(Gidx + 2) * 3] 		= Blue;
					c[(Gidx + 1) * 3 + 1] = c[(Gidx + 2) * 3 + 1] = Green;
					c[(Gidx + 1) * 3 + 2] = c[(Gidx + 2) * 3 + 2] = Red;
				}

				if( R == height - 3 && C == 2 ) // fill the bottom left corner
				{
					c[(Gidx + width - 1) * 3] 		= c[(Gidx + 2 * width - 1) * 3] 		= c[(Gidx + width - 2) * 3] 		= c[(Gidx + 2 * width - 2) * 3] 		= Blue;
					c[(Gidx + width - 1) * 3 + 1] = c[(Gidx + 2 * width - 1) * 3 + 1] = c[(Gidx + width - 2) * 3 + 1] = c[(Gidx + 2 * width - 2) * 3 + 1] = Green;
					c[(Gidx + width - 1) * 3 + 2] = c[(Gidx + 2 * width - 1) * 3 + 2] = c[(Gidx + width - 2) * 3 + 2] = c[(Gidx + 2 * width - 2) * 3 + 2] = Red;
				}

				c[Gidx * 3] 		= Blue;
				c[Gidx * 3 + 1] = Green;
				c[Gidx * 3 + 2] = Red;

		}


		}
		else
		{ // GREEN PIXEL IN RED ROW
			// set some dummy for now
			if( R != 0 && R != 1 && R != (height-2) 	&& R != (height-1) &&
					C != 0 && C != 1 && C != (width -2) 	&& C != (width -1) )
			{

				Red 	= (10 * pLocal[LOidx] +
								8 * (pLocal[LOidx - 1] + pLocal[LOidx + 1])
								- 2 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx - 2] + pLocal[LOidx + 2])
								+ (pLocal[LOidx - (2 * width)] + pLocal[LOidx + (2 * width)])) >> 4;
				Blue 	= (10 * pLocal[LOidx] +
								8 * (pLocal[LOidx - width] + pLocal[LOidx + width])
								- 2 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx - 2 * width] + pLocal[LOidx + 2 * width])
								+ (pLocal[LOidx - 2] + pLocal[LOidx + 2])) >> 4;
				Green = pLocal[LOidx]; // copy G

				Blue = normal(Blue);
				Red = normal(Red);

				if(R == 2)
				{
					c[(Gidx - width) * 3] 			= c[(Gidx - 2 * width) * 3] 			= Blue;
					c[((Gidx - width) * 3) + 1] = c[((Gidx - 2 * width) * 3) + 1] = Green;
					c[((Gidx - width) * 3) + 2] = c[((Gidx - 2 * width) * 3) + 2] = Red;
				}

				if(C == 2)
				{
					c[(Gidx - 1) * 3] 		= c[(Gidx - 2) * 3] 		= Blue;
					c[(Gidx - 1) * 3 + 1] = c[(Gidx - 2) * 3 + 1] = Green;
					c[(Gidx - 1) * 3 + 2] = c[(Gidx - 2) * 3 + 2] = Red;
				}

				if(C == width - 3)
				{
					c[(Gidx + 1) * 3] 		= c[(Gidx + 2) * 3] 		= Blue;
					c[(Gidx + 1) * 3 + 1] = c[(Gidx + 2) * 3 + 1] = Green;
					c[(Gidx + 1) * 3 + 2] = c[(Gidx + 2) * 3 + 2] = Red;
				}

				if( R == 2 && C == width - 3 ) // fill the upper right corner
				{
					c[(Gidx - width + 1) * 3] 		= c[(Gidx - 2 * width + 1) * 3] 		= c[(Gidx - width + 2) * 3] 		= c[(Gidx - 2 * width + 2) * 3] 		= Blue;
					c[(Gidx - width + 1) * 3 + 1] = c[(Gidx - 2 * width + 1) * 3 + 1] = c[(Gidx - width + 2) * 3 + 1] = c[(Gidx - 2 * width + 2) * 3 + 1] = Green;
					c[(Gidx - width + 1) * 3 + 2] = c[(Gidx - 2 * width + 1) * 3 + 2] = c[(Gidx - width + 2) * 3 + 2] = c[(Gidx - 2 * width + 2) * 3 + 2] = Red;
				}

				c[Gidx * 3] 		= Blue;
				c[Gidx * 3 + 1] = Green;
				c[Gidx * 3 + 2] = Red;

			}


		}

	}


}
