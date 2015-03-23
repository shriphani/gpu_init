all: naive

naive:
	nvcc -arch=sm_20 -I ../moderngpu/include ../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp repeat.cu -o naive
