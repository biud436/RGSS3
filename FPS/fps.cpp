#define _FPS_
#include "fps.h"

LARGE_INTEGER g_timerStart;
LARGE_INTEGER g_timerEnd;
LARGE_INTEGER g_timerFreq;
float g_fFrameTime;
float g_fFps;
DWORD   sleepTime;

const float FRAME_RATE  = 200.0f;               
const float MIN_FRAME_RATE = 10.0f;             
const float MIN_FRAME_TIME = 1.0f/FRAME_RATE;  
const float MAX_FRAME_TIME = 1.0f/MIN_FRAME_RATE;

LIBFPS int UpdateFrameTime()
{
	QueryPerformanceCounter(&g_timerEnd);
	g_fFrameTime = (float)(g_timerEnd.QuadPart - g_timerStart.QuadPart) / (float)g_timerFreq.QuadPart;
	
	if (g_fFrameTime < MIN_FRAME_TIME) 
    {
        sleepTime = (DWORD)((MIN_FRAME_TIME - g_fFrameTime)*1000);
        timeBeginPeriod(1);         
        Sleep(sleepTime);           
        timeEndPeriod(1);           
		return 0;
    }
	
	if(g_fFrameTime > MAX_FRAME_TIME)
		g_fFrameTime = MAX_FRAME_TIME;
	
	if (g_fFrameTime > 0.0f)
		g_fFps = (g_fFps * 0.99f) + (0.01f / g_fFrameTime);
		
	g_timerStart = g_timerEnd;
	return 1;
}

LIBFPS float* GetFrameTime()
{
	return &g_fFrameTime;
}

LIBFPS float* GetFPS()
{
	return &g_fFps;
}

LIBFPS int InitFrameTime()
{
	g_fFps = 100;
	
	if(QueryPerformanceFrequency(&g_timerFreq) == FALSE)
	{
		return 0;
	}
	QueryPerformanceCounter(&g_timerStart);
	return 1;
}