__kernel void mhc_kernel_uchar(__global uchar* a, __global uchar* c, const int GrpCount, const int width)
{

	int GLidx = get_global_id(0);

	int range = get_global_size(0);
	int height = range * GrpCount;

	int Tidy, Tidx;

	__local uchar sharedData[5][5];

	for (int index = 0; index < GrpCount; index++)
	{
		int Gidx = (index * range + GLidx);


		char Red, Green, Blue;

		int R = (Gidx / width);		// R = index of Row, Max value is (heigth - 1)
		int C = Gidx - (R * width);		// C = index of Column, Max value is  (width  - 1)

		global uchar* pixel = a + Gidx;
		global uchar* Output_Green = c + Gidx *3;
		//global uchar* Output_Blue = c + Gidx * 3 + 1;
		//global uchar* Output_Red = c + Gidx * 3 + 2 ;


		if ( R % 2 == 0 && C % 2 == 0 )
		{ // RED PIXEL
			Red = 200;
			Blue = 0;
			Green = 0;

			// set some dummy for now
			if( R == 0 || R == 1 )
			{ // two first rows

			}
			else if ( R == height -1 || R == height - 2 )
			{ // last two rows

			}
			else if ( C == 0 || C == 1 )
			{ // first two columns

			}
			else if ( C == width - 1 || C == width -2 )
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

				 Blue = (12*pixel[0]-3*(pixel[-2*width] + pixel[2*width] + pixel[-2] + pixel[2]) + 4*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1])) >> 4;
				 Green = ( 4*pixel[0]+2*(pixel[-width]   + pixel[width]   + pixel[-1] + pixel[1]) - 1*(pixel[-2*width] + pixel[2*width]  + pixel[-2] + pixel[2])) >> 3;
				 Red = pixel[0];   // copy R


			}
			//Red Pixel
			//Red = pixel[0];
			//Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1] + 2) >> 2;
			//Blue = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1] + 2) >> 2;

			//if (R == 0)
			//{ // first row
			//	Green = ( pixel[width] + pixel[-1] + pixel[1]) / 3;
			//	Blue = ( pixel[width - 1]  + pixel[width + 1]) >> 1;
			//}
			//if (R == heigth - 1)
			//{ // last row
			//	Green = (pixel[-width]  + pixel[-1] + pixel[1]) / 3;
			//	Blue = (pixel[-width - 1] + pixel[-width + 1]) >> 1;
			//}
			//if (C == 0)
			//{	// first column
			//	Green = (pixel[-width] + pixel[width] + pixel[1]) / 3;
			//	Blue = (pixel[-width + 1] + pixel[width + 1]) >> 1;
			//}
			//if (C == width - 1)
			//{ // last column
			//	Green = (pixel[-width] + pixel[width] + pixel[-1]) / 3;
			//	Blue = (pixel[-width - 1] + pixel[width - 1]) >> 1;
			//}
			//if (R == 0 && C == 0)
			//{ // first row and column
			//	Green = (pixel[width] + pixel[1]) >> 1;
			//	Blue = pixel[width + 1];
			//}

		}
		else if (R % 2 == 1 && C % 2 == 1)
		{ // BLUE PIXEL
			Red = 0;
			Blue = 200;
			Green = 0;

			// set some dummy for now
			if( R == 0 || R == 1 )
			{ // two first rows

			}
			else if ( R == height -1 || R == height - 2 )
			{ // last two rows

			}
			else if ( C == 0 || C == 1 )
			{ // first two columns

			}
			else if ( C == width - 1 || C == width -2 )
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

				 Green = ( 4*pixel[0]+2*(pixel[-width]   + pixel[width]   + pixel[-1] + pixel[1]) - 1*(pixel[-2*width] + pixel[2*width]  + pixel[-2] + pixel[2])) >> 3;
				 Red = (12*pixel[0]-3*(pixel[-2*width] + pixel[2*width] + pixel[-2] + pixel[2]) + 4*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1])) >> 4;
				 Blue = pixel[0]; // copy B


			}

			//Blue Pixel
			// Blue = pixel[0];
			// Green = (pixel[-width] + pixel[width] + pixel[-1] + pixel[1] + 2) >> 2;
			// Red = (pixel[-width - 1] + pixel[width - 1] + pixel[-width + 1] + pixel[width + 1]+2) >> 2;
      //
			// if (R == 0)
			// {
			// 	Green = (pixel[width] + pixel[-1] + pixel[1]) / 3;
			// 	Red = (pixel[width - 1] + pixel[width + 1]) >> 1;
			// }
			// if (R == heigth - 1)
			// {
			// 	Green = (pixel[-width] + pixel[-1] + pixel[1]) / 3;
			// 	Red = (pixel[-width - 1] + pixel[-width + 1]) >> 1;
			// }
			// if (C == 0)
			// {
			// 	Green = (pixel[-width] + pixel[width] + pixel[1]) / 3;
			// 	Red = (pixel[-width + 1] + pixel[width + 1]) >> 1;
			// }
			// if (C == width - 1)
			// {
			// 	Green = (pixel[-width] + pixel[width] + pixel[-1]) / 3;
			// 	Red = (pixel[-width - 1] + pixel[width - 1]) >> 1;
			// }
			// if (R == heigth - 1 && C == width - 1)
			// {
			// 	Green = (pixel[-width] + pixel[-1]) >> 1;
			// 	Red = pixel[-width - 1];
			// }
		}
		else if (R % 2 == 1 && C % 2 == 0)
		{ // GREEN PIXEL IN BLUE ROW

			// set some dummy for now
			Red = 0;
			Blue = 200;
			Green = 200;
			if( R == 0 || R == 1 )
			{ // two first rows

			}
			else if ( R == height -1 || R == height - 2 )
			{ // last two rows

			}
			else if ( C == 0 || C == 1 )
			{ // first two columns

			}
			else if ( C == width - 1 || C == width -2 )
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

				 Blue = (10*pixel[0] + 8*(pixel[-1]+pixel[1])-2*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1] + pixel[-2] + pixel[2]) + (pixel[-2*width] + pixel[2*width])) >> 4;
				 Red = (10*pixel[0] + 8*(pixel[-width]+pixel[width])-2*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1] + pixel[-2*width] + pixel[2*width]) + (pixel[-2] + pixel[2])) >> 4;
				 Green = pixel[0]; // copy G



			}

			//Green Pixel in Blue row
			// Green = pixel[0];
			// Red = (pixel[-width] + pixel[width] + 1) >> 1;
			// Blue = (pixel[-1] + pixel[1] + 1) >> 1;
      //
			// if (R == 0)
			// {
			// 	Red = (pixel[width]);
			// }
			// if (R == heigth - 1)
			// {
			// 	Red = (pixel[-width]);
			// }
			// if (C == 0)
			// 	Blue = pixel[1];
			// if (C == width - 1)
			// 	Blue = pixel[-1];
		}
		else
		{ // GREEN PIXEL IN RED ROW
			// set some dummy for now
			Red = 200;
			Blue = 0;
			Green = 200;
			if( R == 0 || R == 1 )
			{ // two first rows

			}
			else if ( R == height -1 || R == height - 2 )
			{ // last two rows

			}
			else if ( C == 0 || C == 1 )
			{ // first two columns

			}
			else if ( C == width - 1 || C == width -2 )
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

				 Blue = (10*pixel[0] + 8*(pixel[-width]+pixel[width])-2*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1] + pixel[-2*width] + pixel[2*width]) + (pixel[-2] + pixel[2])) >> 4;
				 Red = (10*pixel[0] + 8*(pixel[-1]+pixel[1])-2*(pixel[-width-1] + pixel[-width+1] + pixel[width-1] + pixel[width+1] + pixel[-2] + pixel[2]) + (pixel[-2*width] + pixel[2*width])) >> 4;
				 Green = pixel[0];  // copy G


			}

			//Green Pixel in Red Row
			// Green = pixel[0];
			// Red = (pixel[-1] + pixel[1] + 1) >> 1;
			// Blue = (pixel[-width] + pixel[width] + 1) >> 1;
      //
			// if (R == 0)
			// {
			// 	Blue = (pixel[width]);
			// }
			// if (R == heigth - 1)
			// {
			// 	Blue = (pixel[-width]);
			// }
			// if (C == 0)
			// 	Red = pixel[1];
			// if (C == width - 1)
			// 	Red = pixel[-1];
		}

		// bound the data between 0 and 255
		char maxVal = 255;
		char minVal = 0;

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

		Output_Green[0] = Blue;
		Output_Green[1] = Green;
		Output_Green[2] = Red;
		//Output_Blue[0] = Green;
		//Output_Red[0] = Red;


	}


}
