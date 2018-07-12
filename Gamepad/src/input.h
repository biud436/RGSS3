#pragma once

#ifdef __cplusplus
extern "C"
{
#endif 

#include <Windows.h>
#include <XInput.h>

#ifdef _RSDLL
#define RSDLL __declspec(dllexport)
#else
#define RSDLL __declspec(dllimport)
#endif

#define WIN32_LEAN_AND_MEAN
#define MAX_CONTROLLERS 4

#pragma comment(lib, "xinput.lib")

	struct ControllerState
	{
		XINPUT_STATE state;
		BOOL connected;
	};

	RSDLL void RSCheckControllers(char* states);

#ifdef __cplusplus
}
#endif