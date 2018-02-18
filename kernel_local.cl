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
	int height = range * GrpCount;


	__local uchar sharedData[10];

	for (int index = 0; index < GrpCount; index++)
	{
		int Gidx = (index * range + GLidx);


		__local int Red, Green, Blue;

		int R = (Gidx / width);		// R = index of Row, Max value is (heigth - 1)
		int C = Gidx - (R * width);		// C = index of Column, Max value is  (width  - 1)


		

		
		__local uchar pLocal[5000];
		pLocal[LOidx - (width * 2)] = a[Gidx - width * 2 ];
		pLocal[LOidx] = a[Gidx];
		pLocal[LOidx + (width * 2) ] =  a[Gidx + width * 2];
		
		barrier(CLK_LOCAL_MEM_FENCE);

		
		if (R % 2 == 0 && C % 2 == 0)
		{ // RED PIXEL

			Green = ((2 * (pLocal[LOidx -width] + pLocal[LOidx-1] + pLocal[LOidx+1] + pLocal[LOidx + width])) +
				(4 * pLocal[LOidx])
				- pLocal[LOidx -2 * width] - pLocal[LOidx -2] - pLocal[LOidx+2] - pLocal[LOidx + 2 * width]) >> 3;
			Blue = ((4 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx +width + 1])) +
				(12 * pLocal[LOidx])
				- 3 * pLocal[LOidx -2 * width] - 3 * pLocal[LOidx-2] - 3 * pLocal[LOidx+2] - 3 * pLocal[LOidx + 2 * width]) >> 4;
			Red = pLocal[LOidx];

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
		
		}
		else if (R % 2 == 1 && C % 2 == 1)
		{ // BLUE PIXEL


			Green = ((2 * (pLocal[LOidx - width] + pLocal[LOidx - 1] + pLocal[LOidx + 1] + pLocal[LOidx + width])) +
				(4 * pLocal[LOidx])
				- pLocal[LOidx - 2 * width] - pLocal[LOidx - 2] - pLocal[LOidx + 2] - pLocal[LOidx + 2 * width]) >> 3;
			Red = ((4 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1])) +
				(12 * pLocal[LOidx])
				- 3 * pLocal[LOidx - 2 * width] - 3 * pLocal[LOidx - 2] - 3 * pLocal[LOidx + 2] - 3 * pLocal[LOidx + 2 * width]) >> 4;
			Blue = pLocal[LOidx];

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
			

		}
		else if (R % 2 == 1 && C % 2 == 0)
		{ // GREEN PIXEL IN BLUE ROW

			// set some dummy for now

			Blue = (10 * pLocal[LOidx] +
				8 * (pLocal[LOidx-1] + pLocal[LOidx +1])
				- 2 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx -2] + pLocal[LOidx+2])
				+ (pLocal[LOidx -(2 * width)] + pLocal[LOidx + (2 * width)])) >> 4;
			Red = (10 * pLocal[LOidx] +
				8 * (pLocal[LOidx -width] + pLocal[LOidx + width])
				- 2 * (pLocal[LOidx -width - 1] + pLocal[LOidx -width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx -2 * width] + pLocal[LOidx +2 * width])
				+ (pLocal[LOidx -2] + pLocal[LOidx+2])) >> 4;
			Green = pLocal[LOidx]; // copy G

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
				
		}
		else
		{ // GREEN PIXEL IN RED ROW
			// set some dummy for now

			Red = (10 * pLocal[LOidx] +
				8 * (pLocal[LOidx - 1] + pLocal[LOidx + 1])
				- 2 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx - 2] + pLocal[LOidx + 2])
				+ (pLocal[LOidx - (2 * width)] + pLocal[LOidx + (2 * width)])) >> 4;
			Blue = (10 * pLocal[LOidx] +
				8 * (pLocal[LOidx - width] + pLocal[LOidx + width])
				- 2 * (pLocal[LOidx - width - 1] + pLocal[LOidx - width + 1] + pLocal[LOidx + width - 1] + pLocal[LOidx + width + 1] + pLocal[LOidx - 2 * width] + pLocal[LOidx + 2 * width])
				+ (pLocal[LOidx - 2] + pLocal[LOidx + 2])) >> 4;
			Green = pLocal[LOidx]; // copy G

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
				
		}

		



		c[Gidx * 3] = Blue;
		c[Gidx * 3 + 1] = Green;
		c[Gidx * 3 + 2] = Red;

	}


}


