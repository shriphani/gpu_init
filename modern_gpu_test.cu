#include "moderngpu.cuh"

using namespace mgpu;

void scanReduceShit(CudaContext &context) {
	int N = 1000;

	int data2[N];

	for (int i = 0; i < N; i++) {
		data2[i] = i;
	}

	int *deviceData2;

	cudaMalloc((void **) &deviceData2, sizeof(int) * N);
	cudaMemcpy((void *) deviceData2, (const void *) data2, sizeof(int) * N, cudaMemcpyHostToDevice);

	// reduce - sum
	int total = Reduce(deviceData2, N, context);
	printf("Total: %d\n", total);

	ScanExc(deviceData2, N, &total, context);
	printf("Total: %d\n", total);

}

int main(int argc, char** argv) {
	ContextPtr context = CreateCudaDevice(argc, argv, true);

	scanReduceShit(*context);

    return 0;
}