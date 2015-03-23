#include <stdio.h>
#include "moderngpu.cuh"

using namespace mgpu;

__global__
void simpleMerge(int *items, int *freqs, int *result, int *pos, int numItems) {

	int gid = threadIdx.x + blockIdx.x * blockDim.x;

	if (gid > numItems) {
		return;
	}

	printf("ThreadId: %d", gid);

	int item = items[gid];
	int freq = freqs[gid];

	int position = pos[gid];

	printf( "Put %d at %d, %d times\n", item, position, freq );

	for (int i = 0; i < freq; i++) {
		result[position+i] = item;
	}
}

int main(int argc, char ** argv) {
	ContextPtr context = CreateCudaDevice(argc, argv, true);

	int N = 5;

	int items[5] = { 2, 5, 8, 2, 10 };
	int freqs[5] = { 10, 3, 0, 6, 5 };

	int CTASize = 1024;
	int numBlocks = 1 + (N / CTASize);

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos, resultSize;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	simpleMerge<<<numBlocks, CTASize>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N);

	int result[resultSize];

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	for (int i = 0; i < resultSize; i++) {
		printf("%d, ", result[i]);
	}

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);
}
