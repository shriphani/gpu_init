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

    int N = 10000;
    int items[100000];
    int freqs[100000];

    for (int i = 0; i < N; i++) {
        items[i] = i;
    }

    for (int i = 0; i < N; i++) {
        freqs[i] = 10;
    }

    int dest[1000000];

    int resultSize;
    int resCount=0;

    int *result = partitionAndRun(items, freqs, N, resultSize, context);
    testRepeat(items, freqs, N, dest, resCount);

    if (resultSize != resCount) {
        delete[] result;
            printf("Fuck up\n%d:%d", resultSize, resCount);
            exit(1);
    }

    for (int i = 0; i < resultSize; i++) {
        if (dest[i] != result[i]) {
            printf("Fuck up\n%d:%d:%d\n", i, result[i], dest[i]);
            delete[] result;
            exit(1);
        }
    }

    delete[] result;
    printf("\n");

}
