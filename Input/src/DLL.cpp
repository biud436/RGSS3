#define _RSDLL
#include "DLL.h"
#include "RGSSInput.h"

// Note that these variables is unsafe thread.
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
		g_hRGSSPlayer = FindWindow(L"RGSS Player", NULL);
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
		rgss_set_mouse_lbutton(TRUE);
		SetFocus(g_hRGSSPlayer);
		break;
	case WM_LBUTTONUP:
		rgss_set_mouse_lbutton(FALSE);
		break;
	case WM_MBUTTONDOWN:
		rgss_set_mouse_mbutton(TRUE);
		break;
	case WM_MBUTTONUP:
		rgss_set_mouse_mbutton(FALSE);
		break;
	case WM_RBUTTONDOWN:
		rgss_set_mouse_rbutton(TRUE);
		break;
	case WM_RBUTTONUP:
		rgss_set_mouse_rbutton(FALSE);
		break;
	case WM_MOUSEWHEEL:
		g_nWheelDelta = (SHORT(HIWORD(wParam)) > 0) ? 1 : -1;
		break;
	case WM_KEYDOWN:
		rgss_set_keydown(wParam);
		break;
	case WM_KEYUP:
		rgss_set_keyup(wParam);
		break;
	case WM_MOUSEMOVE:
		rgss_set_mousemove(lParam);
		break;
	case WM_CHAR:
		ime_composition_pipe1(hWnd, uMsg, wParam, lParam);
		break;
	case WM_IME_COMPOSITION:
		ime_composition_pipe2(hWnd, uMsg, wParam, lParam);
		break;
	case WM_IME_CHAR:
		ime_composition_pipe3(hWnd, uMsg, wParam, lParam);
		break;
	}
	return CallWindowProc(OldProc, hWnd, uMsg, wParam, lParam);
}

RSDLL void RSInitWithCoreSystem()
{
	HINSTANCE hInstance = (HINSTANCE)GetWindowLong(g_hRGSSPlayer, GWL_HINSTANCE);
	OldProc = (WNDPROC)SetWindowLong(g_hRGSSPlayer, GWL_WNDPROC, (LONG)SuperProc);

	rgss_input_init(g_hRGSSPlayer);
}

RSDLL void RSRemoveCoreSystem()
{
	rgss_remove_input();
}

RSDLL void RSResetWheelDelta()
{
	g_nWheelDelta = 0;
}

RSDLL int RSGetWheelDelta()
{
	return g_nWheelDelta;
}