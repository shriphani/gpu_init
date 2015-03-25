CC=nvcc

INCLUDE=../moderngpu/include

MGPU-BUILD=-lmgpu

MGPU-DIR=-L ../moderngpu/

ARCH=sm_30

NV-MODERNGPU=$(CC)  -arch=$(ARCH) -I $(INCLUDE) $(MGPU-BUILD) -lineinfo

NV-MODERNGPU-O=$(CC) -c -arch=$(ARCH) -I $(INCLUDE) -lineinfo

CPP-COMPILER=g++

all: naive binsearch

objects: naive_repeat.o binsearch_repeat.o warp_repeat.o test.o test_even_heavy.o test_skewed_heavy.o test1m.o

%.o: %.cu
	$(NV-MODERNGPU-O) $< -o $@

.PHONY: test
test: test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy

test-binsearch: test.o binsearch_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) test.o binsearch_repeat.o -o test-binsearch $(MGPU-BUILD)

test-naive: test.o naive_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-naive $(MGPU-BUILD)

test-warp-even-heavy: test_even_heavy.o warp_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-warp-even-heavy $(MGPU-BUILD)

test-binsearch-even-heavy: test_even_heavy.o binsearch_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-binsearch-even-heavy $(MGPU-BUILD)

test-naive-even-heavy: test_even_heavy.o naive_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-naive-even-heavy $(MGPU-BUILD)

test-binsearch-skewed-heavy: test_skewed_heavy.o binsearch_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-binsearch-skewed-heavy $(MGPU-BUILD)

test-naive-skewed-heavy: test_skewed_heavy.o naive_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-naive-skewed-heavy $(MGPU-BUILD)

test-1m-even-naive: test1m.o naive_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-1m-even-naive $(MGPU-BUILD)

test-1m-even-warp: test1m.o warp_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-1m-even-warp $(MGPU-BUILD)

test-1m-even-binsearch: test1m.o binsearch_repeat.o
	$(NV-MODERNGPU) $(MGPU-DIR) $^ -o test-1m-even-binsearch $(MGPU-BUILD)

clean:
	rm -rf a.out naive binsearch test-binsearch test-naive test-binsearch-even-heavy test-naive-even-heavy test-binsearch-skewed-heavy test-naive-skewed-heavy