CC=nvcc

INCLUDE=../moderngpu/include

MGPU-BUILD=../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp

ARCH=sm_20

NV-MODERNGPU= $(CC) -arch=$(ARCH) -I $(INCLUDE) $(MGPU-BUILD)

all: naive binsearch

naive:
	$(NV-MODERNGPU) naive_repeat.cu -o naive

binsearch:
	$(NV-MODERNGPU) binsearch_repeat.cu -o binsearch

clean:
	rm -rf a.out naive binsearch