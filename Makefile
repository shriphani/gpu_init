CC=nvcc

INCLUDE=../moderngpu/include

MGPU-BUILD=../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp

ARCH=sm_20

all: naive

naive:
	nvcc -arch=$(ARCH) -I $(INCLUDE) $(MGPU-BUILD) naive_repeat.cu -o naive

binsearch:
	nvcc -arch=sm_20 -I ../moderngpu/include ../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp binsearch_repeat.cu -o binsearch

clean:
	rm a.out naive binsearch