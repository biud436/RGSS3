#ifndef __RS_INPUT_H__
#define __RS_INPUT_H__

#pragma once

#ifdef __cplusplus
extern "C"
{
#endif 

#include <Windows.h>
#include <process.h>
#include <tchar.h>

#define WIN32_LEAN_AND_MEAN

#pragma comment(lib, "winmm.lib")

#define RS_EX_STYLE WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_COMPOSITED 
#define RS_WND_STYLE WS_POPUP

	// 투명색 설정
#define RS_TRANSPARENT_COLOR RGB(0, 255, 0)

#ifdef _RSDLL
#define RSDLL __declspec(dllexport)
#else
#define RSDLL __declspec(dllimport)
#endif

	RSDLL void RSInitWithCoreSystem();
	RSDLL void RSRemoveCoreSystem();
	RSDLL void RSResetWheelDelta();
	RSDLL int RSGetWheelDelta();

#ifdef __cplusplus
}
#endif

#endif 