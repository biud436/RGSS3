#define _RSDLL
#include "DLL.h"
#include <stdio.h>
#include <stdlib.h>

// 핸들
HWND g_hWnd = NULL;

// RGSS301.dll 핸들
HMODULE g_hRGSSSystemDLL = NULL;

// RGSS 플레이어 핸들
HWND g_hRGSSPlayer = NULL;

// DLL 핸들
HINSTANCE g_hDllHandle = NULL;

// 서브 클래싱
WNDPROC OldProc = NULL;
LRESULT CALLBACK SuperProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

// RGSSEVal
typedef int(*RGSSEVAL_PROTO)(char *);
static RGSSEVAL_PROTO gRGSSEval;

RSDLL void Init()
{

	/*freopen("CONOUT$", "wt", stdout);*/
	InitWithRGSS();
	gRGSSEval = (RGSSEVAL_PROTO)GetProcAddress(g_hRGSSSystemDLL, "RGSSEval");
	GetWndProc();
	gRGSSEval("$window_focus = true;");

}

RSDLL void ToggleFPS()
{
	if (g_hRGSSPlayer != NULL) {
		SendMessage(g_hRGSSPlayer, WM_COMMAND, 0x7d2, NULL);
	}
}

RSDLL void SwitchFullScreen()
{
	if (g_hRGSSPlayer != NULL) {
		SendMessage(g_hRGSSPlayer, WM_COMMAND, 0x7d3, NULL);
	}
}

RSDLL void OpenOptionWindow()
{
	if (g_hRGSSPlayer != NULL) {
		SendMessage(g_hRGSSPlayer, WM_SYSCOMMAND, 0x7d1, NULL);
	}
}

void InitWithRGSS()
{
	TCHAR DLLName[MAX_PATH];
	TCHAR RGSSSystemFilePath[MAX_PATH];
	TCHAR IniDir[MAX_PATH];
	TCHAR GameTitle[MAX_PATH];

	// INI 파일 경로 획득
	GetCurrentDirectory(MAX_PATH, IniDir);
	_tcsncat_s(IniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

	// INI을 읽는다
	GetPrivateProfileString(_T("Game"), _T("Library"), _T("RGSS104E.dll"), RGSSSystemFilePath, MAX_PATH, IniDir);
	GetPrivateProfileString(_T("Game"), _T("Title"), _T("Untitled"), GameTitle, MAX_PATH, IniDir);

	g_hRGSSSystemDLL = GetModuleHandle(RGSSSystemFilePath);
	g_hRGSSPlayer = FindWindow(_T("RGSS Player"), NULL);

}

void GetWndProc()
{
	char szStr[MAX_PATH];
	snprintf(szStr, MAX_PATH, "def RS.focus_on; $oldProc = Win32API.new('user32.dll', 'SetWindowLong', ['l', 'i', 'l'], 'l').call(%d, -4, %d);end", g_hRGSSPlayer, (LONG)SuperProc);
	gRGSSEval(szStr);
}


RSDLL void RSCallProc(unsigned long p)
{
	OldProc = (WNDPROC)p;
}

LRESULT CALLBACK SuperProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_SETFOCUS:
		gRGSSEval("$window_focus = true;");
		return 0;
	case WM_KILLFOCUS:
		gRGSSEval("$window_focus = false;");
		return 0;
	case WM_COMMAND:
	case WM_SYSCOMMAND:
		if (OldProc != NULL)
		{
			CallWindowProc(OldProc, hWnd, uMsg, wParam, lParam);
		}
		return 0;
	case WM_DESTROY:
		PostQuitMessage(0);
		return 0;
	}
	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}