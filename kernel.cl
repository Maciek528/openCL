

__kernel void bayer_filter(__global float* a, __global float* c, int width)
{
	// find position in global arrays

	int WGidx = get_group_id(0);
	int WGidy = get_group_id(1);
	int Tidx = get_local_id(0);
	int Tidy = get_local_id(1);
	int Gidx = get_global_id(0);
	int Gidy = get_global_id(1);

	// process 
	
	c[WGidx] = 1;
	printf("kernel: %d\n", WGidx);
	//void *test = a;

	//int strideSrc = width;
	//fl  bla = a;//+ WGidy * strideSrc + WGidx;// locate the position of current pixel
	//void *cDst = c + j * strideDst + i * 3;
}
