#ifndef __DLL_H__
#define __DLL_H__

#include <Windows.h>
#include <tchar.h>

#if defined __cplusplus
extern "C" {
#endif

#ifdef _RSDLL
#define RSDLL __declspec(dllexport)
#else
#define RSDLL __declspec(dllimport)
#endif

	void InitWithRGSS();
	void GetWndProc();

	RSDLL void Init();
	RSDLL void ToggleFPS();
	RSDLL void OpenOptionWindow();
	RSDLL void SwitchFullScreen();
	RSDLL void RSCallProc(unsigned long p);

#ifdef __cplusplus
}
#endif

#endif