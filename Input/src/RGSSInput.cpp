#define _RSDLL
#include "RGSSInput.h"
#include <sstream>
#include <string>

RGSSKeys Keys;
RGSSFunctions* _modules = NULL;
HMODULE _hRGSSSystemDLL = NULL;

wchar_t _szRGSSSystemFilePath[MAX_PATH];
wchar_t _szIniDir[MAX_PATH];
wchar_t _szGameTitle[MAX_PATH];

const char* ToUTF8(const wchar_t* law);

void rgss_input_init(HWND RGSSPlayer)
{
	int i;

	for (i = 0; i < MAX_KEYS; i++) 
	{
		Keys.down[i] = FALSE;
		Keys.pressed[i] = FALSE;
	}

	POINT pt = { 0, };
	GetCursorPos(&pt);
	ScreenToClient(RGSSPlayer, &pt);

	Keys.mouseX = pt.x;
	Keys.mouseY = pt.y;

	Keys.buttons.left = FALSE;
	Keys.buttons.middle = FALSE;
	Keys.buttons.right = FALSE;

	Keys.bComp = FALSE;

	// Read INI files and gets properties.
	GetCurrentDirectory(MAX_PATH, _szIniDir);
	wcsncat_s(_szIniDir, MAX_PATH, L"\\Game.ini", MAX_PATH);
	
	GetPrivateProfileString(L"Game", L"Library", L"System/RGSS301.dll", _szRGSSSystemFilePath, MAX_PATH, _szIniDir);
	GetPrivateProfileStringW(L"Game", L"Title", L"UnTitled", _szGameTitle, MAX_PATH, _szIniDir);

	_hRGSSSystemDLL = GetModuleHandle(_szRGSSSystemFilePath);

	if (_hRGSSSystemDLL == NULL) 
	{
		return;
	}

	_modules = new RGSSFunctions();

#define GETPROC(MODULE_NAME) \
	_modules->_p##MODULE_NAME = (MODULE_NAME##Proto)GetProcAddress(_hRGSSSystemDLL, #MODULE_NAME); \
	if(_modules->_p##MODULE_NAME == NULL) { \
		return; \
	}

	GETPROC(RGSSEval);
	GETPROC(RGSSGetInt);
	GETPROC(RGSSGetBool);
	GETPROC(RGSSSetStringUTF8);
	GETPROC(RGSSGetStringUTF8);
	GETPROC(RGSSSetString);

#undef GETPROC

}

void rgss_remove_input()
{

}

void rgss_set_keydown(WPARAM wParam)
{
	if (wParam < MAX_KEYS) 
	{
		Keys.down[wParam] = TRUE;
		Keys.pressed[wParam] = TRUE;
	}
}

void rgss_set_keyup(WPARAM wParam)
{
	if (wParam < MAX_KEYS) 
	{
		Keys.down[wParam] = FALSE;
	}
}

void rgss_set_mousemove(LPARAM lParam)
{
	Keys.mouseX = LOWORD(lParam);
	Keys.mouseY = HIWORD(lParam);
}

void rgss_set_mouse_lbutton(BOOL t)
{
	Keys.buttons.left = t;
}

void rgss_set_mouse_mbutton(BOOL t)
{
	Keys.buttons.middle = t;
}

void rgss_set_mouse_rbutton(BOOL t)
{
	Keys.buttons.right = t;
}

void ime_composition_pipe1(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	Keys.szChar[0] = (BYTE)wParam;
	Keys.szChar[1] = 0;

	BOOL flag = FALSE;

	if (wParam > 32 && wParam <= 255) {
		flag = TRUE;
	}

	for (int i = 0; i<LOWORD(lParam); i++) {
		
		if (flag) 
		{
			_modules->_pRGSSSetStringUTF8("$input_char", ToUTF8(Keys.szChar));
		}
	}

	Keys.bComp = FALSE;
}

void ime_composition_pipe2(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (lParam & GCS_COMPSTR) {

		Keys.hImc = ImmGetContext(hWnd);
		int len = ImmGetCompositionString(Keys.hImc, GCS_COMPSTR, NULL, 0);

		Keys.szComp = new wchar_t[len + 1];

		ImmGetCompositionString(Keys.hImc, GCS_COMPSTR, Keys.szComp, len);

		Keys.szComp[len] = 0;

		if (len == 0) {
			Keys.bComp = FALSE;
		}
		else {
			Keys.bComp = TRUE;
		}

		_modules->_pRGSSSetStringUTF8("$input_char", ToUTF8(Keys.szComp));

		ImmReleaseContext(hWnd, Keys.hImc);

		delete[] Keys.szComp;

	}
}

void ime_composition_pipe3(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	BOOL flag = FALSE;

	if (IsDBCSLeadByte((BYTE)(wParam >> 8))) {

		Keys.szChar[0] = HIBYTE(LOWORD(wParam));
		Keys.szChar[1] = LOBYTE(LOWORD(wParam));
		Keys.szChar[2] = 0;

		flag = TRUE;

	}
	else {

		Keys.szChar[0] = (BYTE)wParam;
		Keys.szChar[1] = 0;

		if (wParam > 32 && wParam <= 255) {
			flag = TRUE;
		}

	}
	
	if (flag) 
	{
		_modules->_pRGSSSetStringUTF8("$input_char", ToUTF8(Keys.szChar));
	}


	Keys.bComp = FALSE;
}

RSDLL int is_key_down(BYTE virtualKey)
{
	if (virtualKey < MAX_KEYS) {
		return Keys.down[virtualKey];
	}
	else {
		return false;
	}
}

RSDLL int was_key_pressed(BYTE virtualKey)
{
	if (virtualKey < MAX_KEYS) {
		return Keys.pressed[virtualKey];
	}
	else {
		return false;
	}
}

RSDLL long get_mouse_x()
{
	return Keys.mouseX;
}

RSDLL long get_mouse_y()
{
	return Keys.mouseY;
}

RSDLL BOOL get_mouse_lbutton()
{
	return Keys.buttons.left;
}

RSDLL BOOL get_mouse_mbutton()
{
	return Keys.buttons.middle;
}

RSDLL BOOL get_mouse_rbutton()
{
	return Keys.buttons.right;
}

RSDLL void clear()
{
	int i;

	for (i = 0; i < MAX_KEYS; i++)
	{
		Keys.down[i] = FALSE;
		Keys.pressed[i] = FALSE;
	}

}

const char* ToUTF8(const wchar_t* law)
{
	int length = WideCharToMultiByte(CP_UTF8, 0, law, -1, NULL, 0, NULL, NULL) + 2;

	if (length == 2)
	{
		return "";
	}

	char* pBuf = new char[length];

	if (pBuf) 
	{
		memset(pBuf, 0x00, length);
		int ret = WideCharToMultiByte(CP_UTF8, 0, law, -1, pBuf, length, NULL, NULL);
	}

	return pBuf;
}