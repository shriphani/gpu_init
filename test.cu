#include "repeat.cuh"

void testRepeat(int *items, int *freqs, int nItems, int *dest, int &resCount) {
 
    for (int i = 0; i < nItems; i++) {
    	resCount += freqs[i];
    }
    int destIdx = 0;
    for (int i = 0; i < nItems; i++) {
    	for (int j = 0; j < freqs[i]; j++) {
    		dest[destIdx++] = items[i];
    	}
    }
}

int main(int argc, char ** argv) {
	ContextPtr context = CreateCudaDevice(argc, argv, true);

	int items[5] = { 2, 5, 8, 2, 10 };
	int freqs[5] = { 10, 3, 0, 6, 5 };

	int dest[24];

	int N = 5;
	int resultSize;
	int resCount;

	int *result = partitionAndRun(items, freqs, N, resultSize, context);
	testRepeat(items, freqs, N, dest, resCount);
	
	if (resultSize != resCount) {
		delete[] result;
			printf("Fuck up\n");
			exit(1);
	}

	for (int i = 0; i < resultSize; i++) {
		if (dest[i] != result[i]) {
			delete[] result;
			printf("Fuck up\n");
			exit(1);
		}
	}

	delete[] result;
	printf("\n");

}