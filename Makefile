CC=nvcc

INCLUDE=../moderngpu/include

MGPU-BUILD=../moderngpu/src/mgpucontext.cu ../moderngpu/src/mgpuutil.cpp

ARCH=sm_20

NV-MODERNGPU=$(CC) -arch=$(ARCH) -I $(INCLUDE) $(MGPU-BUILD) -lineinfo

CPP-COMPILER=g++

all: naive binsearch

naive:
	$(NV-MODERNGPU) naive_repeat.cu -o naive

binsearch:
	$(NV-MODERNGPU) binsearch_repeat.cu -o binsearch

test: test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy

test-binsearch:
	$(NV-MODERNGPU) test.cu binsearch_repeat.cu -o test-binsearch

test-naive:
	$(NV-MODERNGPU) test.cu naive_repeat.cu -o test-naive

test-warp-even-heavy:
	$(NV-MODERNGPU) test_even_heavy.cu warp_repeat.cu -o test-warp-even-heavy

test-binsearch-even-heavy:
	$(NV-MODERNGPU) test_even_heavy.cu binsearch_repeat.cu -o test-binsearch-even-heavy

test-naive-even-heavy:
	$(NV-MODERNGPU) test_even_heavy.cu naive_repeat.cu -o test-naive-even-heavy

test-binsearch-skewed-heavy:
	$(NV-MODERNGPU) test_skewed_heavy.cu binsearch_repeat.cu -o test-binsearch-skewed-heavy

test-naive-skewed-heavy:
	$(NV-MODERNGPU) test_skewed_heavy.cu naive_repeat.cu -o test-naive-skewed-heavy

test-1m-even-naive:
	$(NV-MODERNGPU) test1m.cu naive_repeat.cu -o test-1m-even-naive

test-1m-even-warp:
	$(NV-MODERNGPU) test1m.cu warp_repeat.cu -o test-1m-even-warp

test-1m-even-binsearch:
	$(NV-MODERNGPU) test1m.cu binsearch_repeat.cu -o test-1m-even-binsearch

clean:
	rm -rf a.out naive binsearch test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy