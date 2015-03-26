#include <stdio.h>
#include "moderngpu.cuh"
#include <math.h>

#define CTA_SIZE 256
#define WARP_SIZE 32

using namespace mgpu;

__global__
void warpRepeat2(int *items, int *freqs, int *result, int *pos, int numItems, int numResults) {

    const int nWarpsPerCTA = CTA_SIZE / WARP_SIZE;
    const int tid = threadIdx.x + (blockDim.x * blockIdx.x);
    const int wid = tid / WARP_SIZE;
    const int lane = tid % WARP_SIZE;
    const int lwid = wid % nWarpsPerCTA;

    // one item per warp
    volatile __shared__ int warpItem[CTA_SIZE / WARP_SIZE];
    volatile __shared__ int warpFreq[CTA_SIZE / WARP_SIZE];
    volatile __shared__ int warpPos[CTA_SIZE / WARP_SIZE];

    if (threadIdx.x < CTA_SIZE / WARP_SIZE) {

        int itemId = nWarpsPerCTA * blockIdx.x + threadIdx.x;

        if (itemId < numItems) {
            warpItem[threadIdx.x] = items[itemId];
            warpFreq[threadIdx.x] = freqs[itemId];
            warpPos[threadIdx.x] = pos[itemId];
        }
    }

    __syncthreads();

    for (int i = lane; i < warpFreq[lwid]; i += 32) {
        //printf("Lane: %d, wid: %d, item %d, position %d\n", lane, wid, warpItem[lwid], warpPos[lwid]);
        int position = warpPos[lwid] + i;
        result[position] = warpItem[lwid];
    }

}

int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	int numBlocks = (N * WARP_SIZE + (CTA_SIZE - 1)) / CTA_SIZE;

	printf("Num blocks: %d\n", numBlocks);

	int *result = new int[resultSize];

	warpRepeat2<<<numBlocks, CTA_SIZE>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N, resultSize);

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);


	return result;
}
