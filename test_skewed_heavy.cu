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
    int freqs[5];
    int N = 5;

    freqs[0] = 1000;
    for (int i = 1; i < N; i++) {
        freqs[i] = 10;
    }

    int dest[1040];

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