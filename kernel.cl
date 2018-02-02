


__kernel void bayer_filter(__global ushort* a, __global ushort* c, const int GrpCount, const int width)
{

	int GLidx = get_global_id(0);
	if (GLidx > (get_global_size(0) / 2))
		return;



	int range = get_global_size(0);
	int heigth = range * GrpCount;
	for (int index = 0; index < GrpCount; index++)
	{
		int Gidx = index * range + GLidx;
		short Red, Green, Blue;

		int I = (Gidx / width);		// I = index of Row, Max value is (heigth - 1)
		int J = Gidx - (I * width);		// J = index of Column, Max value is  (width  - 1)

		global ushort* pixel = a + Gidx;
		global ushort* Output_Green = c + Gidx ;
		global ushort* Output_Blue = c + Gidx * 3 + 1;
		global ushort* Output_Red = c + Gidx * 3 + 2 ;


		if (I % 2 == 0 && J % 2 == 0)
		{
			//Red Pixel
			Red = pixel[0];
			Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1] + 2) >> 2;
			Blue = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1] + 2) >> 2;

			if (I == 0)
			{
				Green = ( pixel[width] + pixel[-1] + pixel[1]) / 3;
				Blue = ( pixel[width - 1]  + pixel[width + 1]) >> 1;
			}
			if (I == heigth - 1)
			{
				Green = (pixel[-width]  + pixel[-1] + pixel[1]) / 3;
				Blue = (pixel[-width - 1] + pixel[-width + 1]) >> 1;
			}
			if (J == 0)
			{
				Green = (pixel[-width] + pixel[width] + pixel[1]) / 3;
				Blue = (pixel[-width + 1] + pixel[width + 1]) >> 1;
			}
			if (J == width - 1)
			{
				Green = (pixel[-width] + pixel[width] + pixel[-1]) / 3;
				Blue = (pixel[-width - 1] + pixel[width - 1]) >> 1;
			}
			if (I == 0 && J == 0)
			{
				Green = (pixel[width] + pixel[1]) >> 1;
				Blue = pixel[width + 1];
			}

		}
		else if (I % 2 == 1 && J % 2 == 1)
		{
			//Blue Pixel
			Blue = pixel[0];
			Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1] + 2) >> 2;
			Red = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]+2) >> 2;

			if (I == 0)
			{
				Green = (pixel[width] + pixel[-1] + pixel[1]) / 3;
				Red = (pixel[width - 1] + pixel[width + 1]) >> 1;
			}
			if (I == heigth - 1)
			{
				Green = (pixel[-width] + pixel[-1] + pixel[1]) / 3;
				Red = (pixel[-width - 1] + pixel[-width + 1]) >> 1;
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
				Green = (pixel[-width] + pixel[-1]) >> 1;
				Red = pixel[-width - 1];
			}
		}
		else if (I % 2 == 1 && J % 2 == 0)
		{
			//Green Pixel in Blue row
			Green = pixel[0];
			Red = (pixel[-width] + pixel[width] + 1) >> 1;
			Blue = (pixel[-1] + pixel[1] + 1) >> 1;

			if (I == 0)
			{
				Red = (pixel[width]);
			}
			if (I == heigth - 1)
			{
				Red = (pixel[-width]);
			}
			if (J == 0)
				Blue = pixel[1];
			if (J == width - 1)
				Blue = pixel[-1];
		}
		else
		{
			//Green Pixel in Red Row
			Green = pixel[0];
			Red = (pixel[-1] + pixel[1] + 1) >> 1;
			Blue = (pixel[-width] + pixel[width] + 1) >> 1;

			if (I == 0)
			{
				Blue = (pixel[width]);
			}
			if (I == heigth - 1)
			{
				Blue = (pixel[-width]);
			}
			if (J == 0)
				Red = pixel[1];
			if (J == width - 1)
				Red = pixel[-1];
		}
		
		Output_Green[0] = Blue;
		Output_Blue[0] = Green;
		Output_Red[0] = Red;
	}
	

}
