#pragma once

#ifdef __cplusplus
	extern "C"
	{
#endif 

#include <Windows.h>
#define WIN32_LEAN_AND_MEAN
#pragma comment(lib, "winmm.lib")

#ifdef _FPS_
	#define LIBFPS __declspec(dllexport)
#else
	#define LIBFPS __declspec(dllimport)
#endif

LIBFPS int UpdateFrameTime();
LIBFPS float* GetFrameTime();
LIBFPS float* GetFPS();
LIBFPS int InitFrameTime();

#ifdef __cplusplus
	}
#endif