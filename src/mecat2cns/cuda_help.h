//Cuda kernel utilities
#include <stdio.h>

#define K_NO_ERR        0
#define K_ASSERT_FAIL   1

#define ENCODE2CHAR "ACGT-"

//for performing computations in kernels that might have errors
typedef struct
{
    unsigned type;
    unsigned line;
    unsigned bid;
    unsigned tid;

}kernel_err_t ;

//cuda lib call wrappers
//from book.h
static void HandleError( cudaError_t err, const char* file, int line)
{
    if(err != cudaSuccess) {
        printf( "%s in %s at line %d\n", cudaGetErrorString(err), file, line);
        exit( EXIT_FAILURE );
    }
}

#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__))

//make sure to cudaFreeHost the kernel_err_t poitner
void kernel_err_init(kernel_err_t ** p)
{
    HANDLE_ERROR(cudaHostAlloc( p, sizeof(kernel_err_t), cudaHostAllocDefault)) ;
    (*p)->type = K_NO_ERR;
}

//checks the kernel_err_t and blows up on failure
void kernel_err_check(kernel_err_t* e)
{
    if(e->type != K_NO_ERR)
    {
        printf("Kernel assertion failed: Type %d, Line %d,(blk, thread), (%d,%d)", e->type, e->line, e->bid, e->tid);
        abort();
    }
}

__device__ __forceinline__ bool  __kernel_r_assert(bool r, kernel_err_t * err, const int line, const int bid, const int tid)
{
    if(r)
    {
        err->type = K_NO_ERR;
    }
    else
    {
        err->type = K_ASSERT_FAIL;
        err->tid = tid;
        err->bid = bid;
        err->line = line;
    }
    return r;
}

//if the condition r is false, fill out details in err and return from kernel
#define kernel_r_assert(r, err)  if( ! __kernel_r_assert(r, err, __LINE__, blockIdx.x, threadIdx.x)) { return;}
