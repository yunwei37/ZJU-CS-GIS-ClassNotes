#include <immintrin.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <arpa/inet.h>

#ifdef RAW_SWAP

inline uint64_t Swap64(uint64_t x)
{
	return (
		((x & 0x00000000000000FF) << 56) |
		((x & 0x000000000000FF00) << 40) |
		((x & 0x0000000000FF0000) << 24) |
		((x & 0x00000000FF000000) << 8) |
		((x & 0x000000FF00000000) >> 8) |
		((x & 0x0000FF0000000000) >> 24) |
		((x & 0x00FF000000000000) >> 40) |
		((x & 0xFF00000000000000) >> 56));
}

inline uint32_t Swap32(uint32_t x)
{
	return (
		((x & 0x000000FF) << 24) |
		((x & 0x0000FF00) << 8) |
		((x & 0x00FF0000) >> 8) |
		((x & 0xFF000000) >> 24));
}

inline uint16_t Swap16(uint16_t x)
{
	return (
		((x & 0x00FF) << 8) |
		((x & 0xFF00) >> 8));
}

#else

inline uint64_t Swap64(uint64_t x)
{
	return __builtin_bswap64(x);
}

inline uint32_t Swap32(uint32_t x)
{
	return __builtin_bswap32(x);
}

inline uint16_t Swap16(uint16_t x)
{
	return __builtin_bswap16(x);
}

#endif

// 8 byte elements
void reverse64_avx2(void *Array, size_t Count)
{
	uint64_t *Array64 = (uint64_t *)(Array);
	size_t i = 0;
	const __m256i ShuffleRev = _mm256_set_epi8(
		8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7,
		8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7);

	for (; i < (Count & ~0b11); i += 4)
	{
		// Load 4 elements
		__m256i bytes = _mm256_loadu_si256(
			(__m256i *)(&Array64[i]));

		// Reverse the byte order of our 32-byte vectors
		bytes = _mm256_shuffle_epi8(bytes, ShuffleRev);

		// Place them back into the array
		_mm256_storeu_si256(
			(__m256i *)(&Array64[i]),
			bytes);
	}

	// Naive swaps for leftover elements
	for (; i < Count; ++i)
	{
		Array64[i] = Swap64(Array64[i]);
	}
}

// 8 byte elements
void reverse32_avx2(void *Array, size_t Count)
{
	uint32_t *Array64 = (uint32_t *)(Array);
	size_t i = 0;
	const __m256i ShuffleRev = _mm256_set_epi8(
		12, 13, 14, 15, 8, 9, 10, 11,  4, 5, 6, 7, 0, 1, 2, 3,
		12, 13, 14, 15, 8, 9, 10, 11,  4, 5, 6, 7, 0, 1, 2, 3);

	for (; i < (Count & ~0b111); i += 8)
	{
		// Load 4 elements
		__m256i bytes = _mm256_loadu_si256(
			(__m256i *)(&Array64[i]));

		// Reverse the byte order of our 32-byte vectors
		bytes = _mm256_shuffle_epi8(bytes, ShuffleRev);

		// Place them back into the array
		_mm256_storeu_si256(
			(__m256i *)(&Array64[i]),
			bytes);
	}

	// Naive swaps for leftover elements
	for (; i < Count; ++i)
	{
		Array64[i] = Swap32(Array64[i]);
	}
}

// 8 byte elements
void reverse32_basic(void *Array, size_t Count)
{
	uint32_t *Array64 = (uint32_t *)(Array);
	size_t i = 0;

	// Naive swaps
	for (; i < Count; ++i)
	{
		Array64[i] = Swap32(Array64[i]);
	}
}


// 8 byte elements
void reverse16_avx2(void *Array, size_t Count)
{
	uint16_t *Array64 = (uint16_t *)(Array);
	size_t i = 0;
	const __m256i ShuffleRev = _mm256_set_epi8(
		14, 15, 12, 13, 10, 11, 8, 9,  6, 7, 4, 5, 2, 3, 0, 1,
		14, 15, 12, 13, 10, 11, 8, 9,  6, 7, 4, 5, 2, 3, 0, 1);

	for (; i < (Count & ~0b1111); i += 16)
	{
		// Load 4 elements
		__m256i bytes = _mm256_loadu_si256(
			(__m256i *)(&Array64[i]));

		// Reverse the byte order of our 32-byte vectors
		bytes = _mm256_shuffle_epi8(bytes, ShuffleRev);

		// Place them back into the array
		_mm256_storeu_si256(
			(__m256i *)(&Array64[i]),
			bytes);
	}

	// Naive swaps for leftover elements
	for (; i < Count; ++i)
	{
		Array64[i] = Swap16(Array64[i]);
	}
}

// 8 byte elements
void reverse16_basic(void *Array, size_t Count)
{
	uint16_t *Array64 = (uint16_t *)(Array);
	size_t i = 0;

	// Naive swaps
	for (; i < Count; ++i)
	{
		Array64[i] = Swap16(Array64[i]);
	}
}

// 8 byte elements
void reverse64_basic(void *Array, size_t Count)
{
	uint64_t *Array64 = (uint64_t *)(Array);
	size_t i = 0;

	// Naive swaps
	for (; i < Count; ++i)
	{
		Array64[i] = Swap64(Array64[i]);
	}
}

#define ELEMENTSIZE 8

void print_array(char *buffer, size_t size)
{
	for (size_t i = 0; i < size; ++i)
	{
		printf("%d ", buffer[i]);
	}
	printf("\n");
}

int test_reverse(size_t count, void(reverse_avx2)(void *Array, size_t Count), void(reverse_basic)(void *Array, size_t Count))
{
	char origin[count * ELEMENTSIZE];
	char res_basic[count * ELEMENTSIZE];
	char res_avx2[count * ELEMENTSIZE];

	for (size_t i = 0; i < count * ELEMENTSIZE; ++i)
	{
		origin[i] = i;
		res_avx2[i] = i;
		res_basic[i] = i;
	}

	reverse_avx2(res_avx2, count);
	reverse_basic(res_basic, count);

	if (memcmp(res_basic, res_avx2, count * ELEMENTSIZE) != 0)
	{
		printf("Error\n");
		print_array(origin, count * ELEMENTSIZE);
		print_array(res_basic, count * ELEMENTSIZE);
		print_array(res_avx2, count * ELEMENTSIZE);
		return 1;
	}
	return 0;
}

#define TEST_COUNT 10000

// return the avg nanoseconds used
long bench(void *buf, size_t array_size, void(reverse)(void *Array, size_t Count))
{
	struct timespec time_start = {0, 0}, time_end = {0, 0};

	clock_gettime(CLOCK_REALTIME, &time_start);

	for (size_t i = 0; i < TEST_COUNT; ++i)
	{
		reverse(buf, array_size);
	}

	clock_gettime(CLOCK_REALTIME, &time_end);

	return (time_end.tv_nsec - time_start.tv_nsec) / TEST_COUNT;
}

#define MAX_ARRAY_SIZE (1 << 18)
uint64_t buffer[MAX_ARRAY_SIZE];

int main(int argc, char *argv[])
{
	// test correctness
	int test_size = 100;
	for (int i = 0; i < TEST_COUNT; ++i)
	{
		if (test_reverse(test_size, reverse64_avx2, reverse64_basic) != 0)
		{
			return 1;
		}
		if (test_reverse(test_size, reverse32_avx2, reverse32_basic) != 0)
		{
			return 1;
		}
		if (test_reverse(test_size, reverse16_avx2, reverse16_basic) != 0)
		{
			return 1;
		}
	}

	// test performance
	printf("| array size | avx2 64bit | basic 64bit | avx2 32bit | basic 32bit | avx2 16bit | basic 16bit |\n");
	for (int i = 0; i < 13; ++i)
	{
		size_t array_size = 4 << i;
		long ns_avx_64 = bench(buffer, array_size, reverse64_avx2);
		long basic_avx_64 = bench(buffer, array_size, reverse64_basic);
		long ns_avx_32 = bench(buffer, array_size, reverse32_avx2);
		long basic_avx_32 = bench(buffer, array_size, reverse32_basic);
		long ns_avx_16 = bench(buffer, array_size, reverse16_avx2);
		long basic_avx_16 = bench(buffer, array_size, reverse16_basic);
		printf("| %10lu | %8ldns | %8ldns | %8ldns | %8ldns | %8ldns | %8ldns |\n",
			   array_size, ns_avx_64, basic_avx_64, ns_avx_32, basic_avx_32, ns_avx_16, basic_avx_16);
	}
	return 0;
}
