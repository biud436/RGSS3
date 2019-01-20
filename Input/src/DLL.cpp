#define _RSDLL
#include "DLL.h"

HINSTANCE g_hDllHandle = NULL;
HWND g_hRGSSPlayer = NULL;
int g_nWheelDelta = 0;
WNDPROC OldProc;
LRESULT CALLBACK SuperProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

/************************************************************************/
/* DllMain                                                              */
/************************************************************************/

BOOL WINAPI DllMain(HINSTANCE hDllHandle,
	DWORD     nReason,
	LPVOID    Reserved)
{

	//  Perform global initialization.

	switch (nReason)
	{
	case DLL_PROCESS_ATTACH:
	{
		g_hDllHandle = hDllHandle;
		g_hRGSSPlayer = FindWindow("RGSS Player", NULL);
		SetFocus(g_hRGSSPlayer);
		RSInitWithCoreSystem();
	}
	break;

	case DLL_PROCESS_DETACH:
		RSRemoveCoreSystem();
		break;
	}

	return TRUE;

}

LRESULT CALLBACK SuperProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_LBUTTONDOWN:
		SetFocus(g_hRGSSPlayer);
		break;
	case WM_MOUSEWHEEL:
		g_nWheelDelta = (SHORT(HIWORD(wParam)) > 0) ? 1 : -1;
		break;
	}
	return CallWindowProc(OldProc, hWnd, uMsg, wParam, lParam);
}

RSDLL void RSInitWithCoreSystem()
{
	HINSTANCE hInstance = (HINSTANCE)GetWindowLong(g_hRGSSPlayer, GWL_HINSTANCE);
	OldProc = (WNDPROC)SetWindowLong(g_hRGSSPlayer, GWL_WNDPROC, (LONG)SuperProc);
}

RSDLL void RSRemoveCoreSystem()
{

}

RSDLL void RSResetWheelDelta()
{
	g_nWheelDelta = 0;
}

RSDLL int RSGetWheelDelta()
{
	return g_nWheelDelta;
}