#include <stdio.h>
#include "moderngpu.cuh"

#define EXIT_SUCCESS 0

using namespace mgpu;

/**
 * 
 * Repeat based on binary search
 * Build a positions list (using a scan)
 * Work is divided based on the final results list
 * What idiot to plug in where is decided based on a binary search in
 * the positions list
 **/
__global__
void binarySearchRepeat(int *items, int *freqs, int *result, int *pos, int numItems, int numResults) {

	// writing to
	int gid = threadIdx.x + (blockIdx.x * blockDim.x);

	if (gid >= numResults) {
		return;
	}

	// what to write
	int itemIdx = BinarySearch<MgpuBoundsLower>(pos, numItems, gid, less_equal<int>());

	result[gid] = items[itemIdx - 1]; 

}

/**
 * Set parts up and so on.
 **/
int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {

	int CTASize = 1024;

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	int numBlocks = 1 + (resultSize / CTASize);

	int *result = new int[resultSize];

	binarySearchRepeat<<<numBlocks, CTASize>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N, resultSize);

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);	


	return result;
}

int main(int argc, char ** argv) {
	ContextPtr context = CreateCudaDevice(argc, argv, true);

	int items[5] = { 2, 5, 8, 2, 10 };
	int freqs[5] = { 10, 3, 0, 6, 5 };

	int N = 5;
	int resultSize;

	int *result = partitionAndRun(items, freqs, N, resultSize, context);
	
	for (int i = 0; i < resultSize; i++) {
		printf("%d, ", result[i]);
	}

	printf("\n");

	delete[] result;

}
