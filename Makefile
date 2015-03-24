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

test: test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy

test-binsearch:
	$(NV-MODERNGPU) test.cu binsearch_repeat.cu -o test-binsearch

test-naive:
	$(NV-MODERNGPU) test.cu naive_repeat.cu -o test-naive

test-binsearch-even-heavy:
	$(NV-MODERNGPU) test_even_heavy.cu binsearch_repeat.cu -o test-binsearch-even-heavy

test-naive-even-heavy:
	$(NV-MODERNGPU) test_even_heavy.cu naive_repeat.cu -o test-naive-even-heavy

test-binsearch-skewed-heavy:
	$(NV-MODERNGPU) test_skewed_heavy.cu binsearch_repeat.cu -o test-binsearch-skewed-heavy

test-naive-skewed-heavy:
	$(NV-MODERNGPU) test_skewed_heavy.cu naive_repeat.cu -o test-naive-skewed-heavy

clean:
	rm -rf a.out naive binsearch test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy