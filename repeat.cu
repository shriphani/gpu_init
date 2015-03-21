#include<stdio.h>

__global__
void simpleMerge(int *items, int *freqs, int *result, int *pos) {

	int idx = threadIdx.x;

	printf("ThreadId: %d", idx);

	int item = items[idx];
	int freq = freqs[idx];

	int position = pos[idx];

	printf( "Put %d at %d, %d times\n", item, position, freq );

	for (int i = 0; i < freq; i++) {
		result[position+i] = item;
	}

	__syncthreads();
}



int main(void) {

	int items[5] = { 2, 5, 8, 2, 10 };
	int freqs[5] = { 10, 3, 0, 6, 5 };
	
	int pos[5];

	int *deviceItems, *deviceFreqs, *result, *devicePos;

	int resultSize = 0;

	for (int i = 0; i < 5; i++) {
		resultSize += freqs[i];
	}

	printf("%d\n", resultSize);
	fflush( stdout );

	int hostResult[resultSize];

	int curPos = 0;
	for (int i = 0; i < 5; i++) {

		if (i == 0) {
			pos[i] = 0;
		}
		else {
			curPos += freqs[i-1];
			pos[i] = curPos;
		}

	}

	printf("%d\n", curPos);

	cudaMalloc( (void **)&deviceItems, 5 * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, 5 * sizeof(int));
	cudaMalloc( (void **)&result, resultSize * sizeof(int));
	cudaMalloc( (void **)&devicePos, 5 * sizeof(int));
	

	cudaMemcpy( deviceItems, items, 5 * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, 5 * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos,   pos, 5 * sizeof(int), cudaMemcpyHostToDevice);

	simpleMerge<<<1,5>>>(deviceItems, deviceFreqs, result, devicePos);

	cudaMemcpy( hostResult, result, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	for (int i = 0; i < resultSize; i++) {
		printf("%d, ", hostResult[i]);
	}
}
