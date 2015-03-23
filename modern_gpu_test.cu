#include "moderngpu.cuh"

using namespace mgpu;

void scanReduceShit(CudaContext &context) {
	int N = 1000;

	MGPU_MEM(int) data = context.GenRandom<int>(N, 0, 9);
	printf("Input Array\n");
	PrintArray(*data, "%4d", 10);

	// reduce - sum
	int total = Reduce(data->get(), N, context);
	printf("Total: %d\n", total);

	// reduce - max
	int reduce;
	Reduce(data->get(), N, INT_MIN, maximum<int>(), (int*)0, &reduce, context);
	printf("Max: %d", reduce);
}

int main(int argc, char** argv) {
	ContextPtr context = CreateCudaDevice(argc, argv, true);

	scanReduceShit(*context);

    return 0;
}