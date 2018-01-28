
__kernel void bayer_filter(__global uchar* a, __global uchar* c, const int range, const int index, const int width)
{
	// find position in global arrays

	int WGidx = get_group_id(0);
	int WGidy = get_group_id(1);
	int Tidx = get_local_id(0);
	int Tidy = get_local_id(1);
	int Gidx = get_global_id(0);
	int Gidy = get_global_id(1);

	

	if (!(Gidx >= (range * index) && Gidx < (range * (index + 1))))
		return;

	
	int Red, Green, Blue;

	int heigth = get_global_size(0) / width;
	int I = ( Gidx / width);		// I = index of Row, Max value is (heigth - 1)
	int J = Gidx - (I * width);		// J = index of Column, Max value is  (width  - 1)

	global uchar* pixel = a + Gidx;
	global uchar* Output_Green = c + (Gidx - (range * index)) * 3;
	global uchar* Output_Blue = c + (Gidx - (range * index)) * 3 + 1;
	global uchar* Output_Red = c + (Gidx - (range * index)) * 3 + 2; 
	


	if (I % 2 == 0 && J % 2 == 0)
	{
		//Red Pixel
		Red = pixel[0];
		Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) >> 2;
		Blue = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) >> 2;
		
		if (I == 0 || I == heigth - 1) 
		{
			Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) /3;
			Blue = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) >> 1;
		}
		if (J == 0)
		{
			Green = (pixel[-width] + pixel[width] + pixel[1]) / 3;
			Blue = ( pixel[-width + 1] + pixel[width + 1]) >> 1;
		}
		if (J == width - 1)
		{
			Green = (pixel[-width] + pixel[width] + pixel[-1] ) / 3;
			Blue = (pixel[-width - 1] + pixel[width - 1]) >> 1;
		}
		if (I == 0 && J == 0)
		{
			Green = ( pixel[width] +  pixel[1]) >> 1;
			Blue =   pixel[width + 1] ;
		}

	}
	else if(I % 2 == 1 && J % 2 == 1)
	{
		//Blue Pixel
		Blue = pixel[0];
		Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) >> 2;
		Red = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) >> 2;

		if (I == 0 || I == heigth - 1)
		{
			Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) / 3;
			Red = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) >> 1;
		}
		if (J == 0)
		{
			Green = (pixel[-width] + pixel[width] + pixel[1]) / 3;
			Red = (pixel[-width + 1] + pixel[width + 1]) >> 1;
		}
		if (J == width - 1)
		{
			Green = (pixel[-width] + pixel[width] + pixel[-1]) / 3;
			Red = (pixel[-width - 1] + pixel[width - 1]) >> 1;
		}
		if (I == heigth - 1 && J == width - 1)
		{
			Green = (pixel[-width] + pixel[-1] ) >> 1;
			Red = pixel[-width - 1];
		}
	}
	else if(I % 2 == 1 && J % 2 == 0)
	{
		//Green Pixel in Blue row
		Green = pixel[0];
		Red = (pixel[-width] + pixel[width]) >> 1;
		Blue = (pixel[-1] + pixel[1]) >> 1;
		
		if (I == 0 || I == heigth - 1)
		{
			Red = (pixel[-width] + pixel[width]);
		}
		if (J == 0 )
			Blue =  pixel[1];
		if (J == width - 1)
			Blue = pixel[-1];
	}
	else
	{
		//Green Pixel in Red Row
		Green = pixel[0];
		Red = (pixel[-1] + pixel[1]) >> 1;
		Blue = (pixel[-width] + pixel[width]) >> 1;

		if (I == 0 || I == heigth - 1)
		{
			Blue = (pixel[-width] + pixel[width]);
		}
		if (J == 0)
			Red = pixel[1];
		if (J == width - 1)
			Red = pixel[-1];
	}
	
	Output_Green[0] = Blue;
	Output_Blue[0] = Green;//pixel[0];
	Output_Red[0] =  Red;

	

}
