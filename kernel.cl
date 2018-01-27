

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

	global uchar* pixel = a + Gidx;
	global uchar* Output = c + (Gidx - (range * index)) ;
	
	int Red, Green, Blue;

	int heigth = get_global_size(0) / width;
	int I = Gidx % width;
	int J = (Gidx / width) % heigth;

	if (I % 2 == 0 && J % 2 == 0)
	{
		//Red Pixel
		Red = pixel[0];
		Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) / 4;
		Blue = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) / 4;
		Output[0] = Red;
	}
	else if(I % 2 == 1 && J % 2 == 1)
	{
		//Blue Pixel
		Blue = pixel[0];
		Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1]) / 4;
		Red = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]) / 4;
		Output[0] = Blue;
	}
	else
	{
		//Green Pixel
		Green = pixel[0];
		Red = (pixel[-1] + pixel[1]) / 2;
		Blue = (pixel[-width] + pixel[width]) / 2;
		Output[0] = Green;
	}



	/*Output[0] = Red;
	Output[1] = Green;
	Output[2] = Blue;*/

}
