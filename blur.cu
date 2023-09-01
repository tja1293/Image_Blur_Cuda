#include <stdio.h>
#include <stdlib.h>

#include "lodepng.h"

//each pixel has 4 values (0 - 255)
//R - RED
//G - GREEN
//B - BLUE
//Transparency (Alpha)


__global__ void Blureffect(unsigned char * inputImage, unsigned char * outputImage, unsigned int *width, unsigned int *height){

int r;
int g;
int b;
int a;

int threadID = blockDim.x * blockIdx.x + threadIdx.x;

int pixel = threadID * 4;

unsigned int w = *width;
unsigned int h = *height;

r = inputImage[pixel];
g = inputImage[pixel+1];
b = inputImage[pixel+2];
a = inputImage[pixel+3];

if(threadID == 0) // Top Left corner
	{

		r = (inputImage[pixel] + inputImage[pixel+4] + inputImage[pixel + (4*w)] + inputImage[(pixel + (4 * w))+4]) / 4;
		g = (inputImage[pixel+1] + inputImage[(pixel+4)+1] + inputImage[(pixel + (4*w))+1] + inputImage[((pixel + (4 * w))+4)+1]) / 4;
		b = (inputImage[pixel+2] + inputImage[(pixel+4)+2] + inputImage[(pixel + (4*w))+2] + inputImage[((pixel + (4 * w))+4)+2]) / 4;

	} 
else if (threadID == w - 1) // Top Right
	{

		r = (inputImage[pixel] + inputImage[pixel - 4] + inputImage[pixel + (w * 4)] + inputImage[pixel + (w * 4) - 4]) / 4;
		g = (inputImage[pixel +1] + inputImage[pixel - 4 + 1] + inputImage[pixel + (w * 4) + 1] + inputImage[pixel + (w * 4) - 4 + 1]) / 4;
		b = (inputImage[pixel +2] + inputImage[pixel - 4 + 2] + inputImage[pixel + (w * 4) + 2] + inputImage[pixel + (w * 4) - 4 + 2]) / 4;
	
	}

else if (threadID == w * (h -1)) // Bottom left
	{
	
		r = (inputImage[pixel] + inputImage[pixel - (w * 4)] + inputImage[pixel - (w * 4) + 4] + inputImage[pixel + 4]) / 4;
		g = (inputImage[pixel+1] + inputImage[pixel - (w * 4)+1] + inputImage[pixel - (w * 4) + 4+1] + inputImage[pixel + 4+1]) / 4;
		b = (inputImage[pixel+2] + inputImage[pixel - (w * 4)+2] + inputImage[pixel - (w * 4) + 4+2] + inputImage[pixel + 4+2]) / 4;
	}
	
else if (threadID == (w * h)-1) // Bottom right
	{

		r = (inputImage[pixel] + inputImage[pixel - 4] + inputImage[pixel - (w * 4) - 4] + inputImage[pixel - (w * 4)]) / 4;
		g = (inputImage[pixel + 1] + inputImage[pixel - 4 + 1] + inputImage[pixel - (w * 4) - 4 + 1] + inputImage[pixel - (w * 4) + 1]) / 4;
		b = (inputImage[pixel + 2] + inputImage[pixel - 4 + 2] + inputImage[pixel - (w * 4) - 4 + 2] + inputImage[pixel - (w * 4) + 2]) / 4;

	}
	
else if (threadID > 0 && threadID < (w - 1)) // Top Row
	{
		
		r = (inputImage[pixel] + inputImage[pixel + 4] + inputImage[pixel + 4 + (w * 4)] + inputImage[pixel + (w * 4)] + inputImage[pixel - 4 + (w * 4)] + inputImage[pixel - 4]) / 6;
		g = (inputImage[pixel +1] + inputImage[pixel + 4 +1] + inputImage[pixel + 4 + (w * 4) +1] + inputImage[pixel + (w * 4) +1] + inputImage[pixel - 4 + (w * 4) +1] + inputImage[pixel - 4 +1]) / 6;
		b = (inputImage[pixel +2] + inputImage[pixel + 4 +2] + inputImage[pixel + 4 + (w * 4) +2] + inputImage[pixel + (w * 4) +2] + inputImage[pixel - 4 + (w * 4) +2] + inputImage[pixel - 4 +2]) / 6;
	}

else if (threadID > (w * (h - 1)) && threadID < (w * h) - 1) // Bottom Row
	{
		
		r = (inputImage[pixel] + inputImage[pixel - 4] + inputImage[pixel - (w * 4) - 4] + inputImage[pixel - (w * 4)] + inputImage[pixel - (w * 4) + 4]  + inputImage[pixel + 4]) / 6;
		g = (inputImage[pixel + 1] + inputImage[pixel - 4 + 1] + inputImage[pixel - (w * 4) - 4 + 1] + inputImage[pixel - (w * 4) + 1] + inputImage[pixel - (w * 4) + 4 + 1]  + inputImage[pixel + 4 + 1]) / 6;
		b = (inputImage[pixel + 2] + inputImage[pixel - 4 + 2] + inputImage[pixel - (w * 4) - 4 + 2] + inputImage[pixel - (w * 4) + 2] + inputImage[pixel - (w * 4) + 4 + 2]  + inputImage[pixel + 4 + 2]) / 6;
	}

else if (threadID % w == 0) // Left Row
	{
		r = (inputImage[pixel] + inputImage[pixel - (w * 4)] + inputImage[pixel - (w * 4) + 4] + inputImage[pixel + 4] + inputImage[pixel + (w * 4) + 4] + inputImage[pixel + (w * 4)]) / 6;
		g = (inputImage[pixel + 1] + inputImage[pixel - (w * 4) + 1] + inputImage[pixel - (w * 4) + 4 + 1] + inputImage[pixel + 4 + 1] + inputImage[pixel + (w * 4) + 4 + 1] + inputImage[pixel + (w * 4) + 1]) / 6;
		b = (inputImage[pixel + 2] + inputImage[pixel - (w * 4) + 2] + inputImage[pixel - (w * 4) + 4 + 2] + inputImage[pixel + 4 + 2] + inputImage[pixel + (w * 4) + 4 + 2] + inputImage[pixel + (w * 4) + 2]) / 6;
	}

else if (threadID % w == w-1) // Right Side
	{
	
		r = (inputImage[pixel] + inputImage[pixel + (w * 4)] + inputImage[pixel + (w * 4) - 4] + inputImage[pixel - 4] + inputImage[pixel - (w * 4) - 4] + inputImage[pixel - (w * 4)]) / 6;
		g = (inputImage[pixel + 1] + inputImage[pixel + (w * 4) + 1] + inputImage[pixel + (w * 4) - 4 + 1] + inputImage[pixel - 4 + 1] + inputImage[pixel - (w * 4) - 4 + 1] + inputImage[pixel - (w * 4) + 1]) / 6;
		b = (inputImage[pixel + 2] + inputImage[pixel + (w * 4) + 2] + inputImage[pixel + (w * 4) - 4] + 2 + inputImage[pixel - 4 + 2] + inputImage[pixel - (w * 4) - 4 + 2] + inputImage[pixel - (w * 4) + 2]) / 6;
	}
	
else
	{
	
		r = (inputImage[pixel] + inputImage[pixel - 4] + inputImage[pixel - (w * 4) - 4] + inputImage[pixel - (w * 4)] + inputImage[pixel - (w * 4) + 4] + inputImage[pixel + 4] + inputImage[pixel + (w * 4) + 4] + inputImage[pixel + (w * 4)] + inputImage[pixel + (w * 4) - 4]) / 9;
		g = (inputImage[pixel + 1] + inputImage[pixel - 4 + 1] + inputImage[pixel - (w * 4) - 4 + 1] + inputImage[pixel - (w * 4) + 1] + inputImage[pixel - (w * 4) + 4 + 1] + inputImage[pixel + 4 + 1] + inputImage[pixel + (w * 4) + 4 + 1] + inputImage[pixel + (w * 4) + 1] + inputImage[pixel + (w * 4) - 4 + 1]) / 9;
		b = (inputImage[pixel + 2] + inputImage[pixel - 4 + 2] + inputImage[pixel - (w * 4) - 4 + 2] + inputImage[pixel - (w * 4) + 2] + inputImage[pixel - (w * 4) + 4 + 2] + inputImage[pixel + 4 + 2] + inputImage[pixel + (w * 4) + 4 + 2] + inputImage[pixel + (w * 4) + 2] + inputImage[pixel + (w * 4) - 4 + 2]) / 9;
		
	}
	
outputImage[pixel] = r;
outputImage[pixel+1] = g;
outputImage[pixel+2] = b;
outputImage[pixel+3] = a;


}

int main(int argc, char ** argv){

	//decode
	//process
	//encode

	unsigned int errorDecode;
	unsigned char* blurredimage; //hold image values
	unsigned int width, height;

	char * filename = argv[1];
	char *newFilename = argv[2];
	
	errorDecode = lodepng_decode32_file(&blurredimage, &width, &height, filename);
	
	if(errorDecode){
		printf("error %u: %s\n", errorDecode, lodepng_error_text(errorDecode));
	}
	
	int arraySize = width*height*4;
	int memorySize = arraySize * sizeof(unsigned char);
	
	unsigned char* gpuInput;
	unsigned char* gpuOutput;
	
	unsigned int* gpuWidth;
	unsigned int* gpuHeight;
	
	unsigned int* cpuWidth = &width;
	unsigned int* cpuHeight = &height;
	
	unsigned char cpuOutput[arraySize];
	
	cudaMalloc( (void**) &gpuInput, memorySize);
	cudaMalloc( (void**) &gpuOutput, memorySize);
	
	cudaMalloc( (void**) &gpuWidth, sizeof(int));
	cudaMalloc( (void**) &gpuHeight, sizeof(int));
	
	cudaMemcpy(gpuInput, blurredimage, memorySize, cudaMemcpyHostToDevice);
	
	cudaMemcpy(gpuWidth, cpuWidth, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(gpuHeight, cpuHeight, sizeof(int), cudaMemcpyHostToDevice);

	Blureffect<<< dim3(height,1,1), dim3(width,1,1) >>>(gpuInput, gpuOutput, gpuWidth, gpuHeight);
	cudaDeviceSynchronize();
	
	cudaMemcpy(cpuOutput, gpuOutput, memorySize, cudaMemcpyDeviceToHost);
	
	lodepng_encode32_file(newFilename, cpuOutput, width, height);


	return 0;
}













