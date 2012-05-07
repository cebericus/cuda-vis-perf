/*
 * Copyright 1993-2010 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */

 /* This example demonstrates how to use the Cuda OpenGL bindings with the
  * runtime API.
  * Device code.
  */

#ifndef _SIMPLEGL_KERNEL_H_
#define _SIMPLEGL_KERNEL_H_


//! Simple kernel to show threads as vertices
//! @param data  data in global memory

__global__ void kernel(float4* pos, unsigned int width, unsigned int height, float time)
{
    unsigned int x = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned int y = blockIdx.y*blockDim.y + threadIdx.y;

    // calculate xy coordinates
    float x1 = x / (float) width;
    float y1 = y / (float) height;

    unsigned int z;		// z axis var will report clock cycle by changing "height"
    //asm( ".target sm_20;\n\t"
    //	 "st.u32 %z, %%clock;\n\t" );

    asm( 	".reg .u32 r1;\n\t"
    		"mov.u32 r1, %%clock;\n\t"
    		"st.local.u32 [%0], r1;\n\t"
    		: "=r"(z)
    	);

    // write output vertex
    pos[y*width+x] = make_float4(x1, y1, z, 1.0f);
}

// Wrapper for the __global__ call that sets up the kernel call
extern "C" void launch_kernel(float4* pos, unsigned int mesh_width, unsigned int mesh_height, float time)
{
    // execute the kernel
    dim3 block(8, 8, 1);
    dim3 grid(mesh_width / block.x, mesh_height / block.y, 1);
    kernel<<< grid, block>>>(pos, mesh_width, mesh_height, time);
}

#endif // #ifndef _SIMPLEGL_KERNEL_H_
