#include<stdio.h>

__global__
void cpTest(int *x) {
	int idx = threadIdx.x;

	printf( "At id: %d, Val: %d", idx, x[idx] );


}

int main(void) {

	int foo[5] = { 1, 2, 3, 4, 5 };

	int *deviceFoo;

	cudaMalloc( (void **)&deviceFoo, 5 * sizeof(int) );
	cudaMemcpy( deviceFoo, foo, 5 * sizeof(int), cudaMemcpyHostToDevice );

	cpTest<<<1, 5>>>(deviceFoo);
	fflush(stdout);

}
