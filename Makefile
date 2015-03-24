CC=nvcc

INCLUDE=../moderngpu/include

MGPU-BUILD=../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp

ARCH=sm_20

NV-MODERNGPU=$(CC) -arch=$(ARCH) -I $(INCLUDE) $(MGPU-BUILD)

CPP-COMPILER=g++

all: naive binsearch

naive:
	$(NV-MODERNGPU) naive_repeat.cu -o naive

binsearch:
	$(NV-MODERNGPU) binsearch_repeat.cu -o binsearch

test: test-binsearch

test-binsearch: binsearch
	$(CPP-COMPILER) test.cpp binsearch	-o test-binsearch

clean:
	rm -rf a.out naive binsearch