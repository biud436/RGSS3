#define _RSDLL
#include "RGSSInput.h"
#include <iostream>
#include <vector>
#include <memory>


RGSSKeys       Keys;

RGSSFunctions* _modules = NULL;
HMODULE        _hRGSSSystemDLL = NULL;

wchar_t        _szRGSSSystemFilePath[MAX_PATH];
wchar_t        _szIniDir[MAX_PATH];
wchar_t        _szGameTitle[MAX_PATH];

const          wchar_t* ToUTF16(const char* raw);
std::string ToUTF8(const std::wstring &wstr);

BOOL RGSSKeys::is_valid_character(int keycode)
{
	BOOL ret = FALSE;

#define CHECK(A, B) \
	(keycode >= A && keycode <= B)

	if (CHECK(0x00, 0x07F))  // 영문, 숫자, 기호
		ret = TRUE;
	else if (CHECK(0x80, 0x1FF)) // 라틴어
		ret = TRUE;
	else if (CHECK(0x250, 0x36F))
		ret = TRUE;
	else if (CHECK(0x400, 0x58F))
		ret = TRUE;
	else if (CHECK(0x590, 0x6FF))
		ret = TRUE;
	else if (CHECK(0x1100, 0x11FF)) // 한글 초성, 중성, 종성
		ret = TRUE;
	else if (CHECK(0x3040, 0x30FF))
		ret = TRUE;
	else if (CHECK(0x3131, 0x319E)) // 한글 자모음
		ret = TRUE;
	else if (CHECK(0x4E00, 0x9FBB))
		ret = TRUE;
	else if (CHECK(0xAC00, 0xD7A3)) // 한글
		ret = TRUE;
	else
		ret = FALSE;

	if (keycode == '\r') {
		Keys.isNewLine = TRUE;
		ret = FALSE;
	}
	else if (keycode == '\b') {
		Keys.isBackspace = TRUE;
	}

#undef CHECK

	if (ret) {
		printf("correct keycode : %X\n", keycode);
	}
	else {
		printf("incorrect keycode : %X\n", keycode);
	}

	return ret;
}

BOOL RGSSKeys::is_hangul_character(int keycode)
{
	BOOL ret = FALSE;

#define CHECK(A, B) \
	(keycode >= A && keycode <= B)

	if (CHECK(0x1100, 0x11FF)) // 한글 초성, 중성, 종성
		ret = TRUE;
	else if (CHECK(0x3131, 0x319E)) // 한글 자모음
		ret = TRUE;
	else if (CHECK(0xAC00, 0xD7A3)) // 한글
		ret = TRUE;
	else
		ret = FALSE;

#undef CHECK

	return ret;
}

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
	Keys.isRGSS3 = FALSE;

	Keys.bComp = FALSE;

	Keys.isNewLine = FALSE;
	Keys.isBackspace = FALSE;
	Keys.request_remove = FALSE;
	
	Keys.buf = _T("");
	Keys.immutableTexts = _T("");
	Keys.buf.resize(MAX_TEXT_BUFFS);

	Keys.counter = 0;

	// Read INI files and gets properties.

	std::wstring sIniDir;
	sIniDir.resize(MAX_PATH + 1);

	GetCurrentDirectoryW(MAX_PATH, &sIniDir[0]);
	sIniDir.resize(lstrlen(&sIniDir[0]));
	sIniDir += L"\\Game.ini";

	std::vector<wchar_t> buf(MAX_PATH);
	GetPrivateProfileStringW(L"Game", L"Library", L"System\\RGSS301.dll", buf.data(), MAX_PATH, &sIniDir[0]);
	std::wstring sRGSSSystemFilePath(buf.data(), buf.data() + lstrlen(buf.data()));

	GetPrivateProfileStringW(L"Game", L"Title", L"UnTitled", buf.data(), MAX_PATH, &sIniDir[0]);
	std::wstring sGameTitle(buf.data(), buf.data() + lstrlen(buf.data()));

	_hRGSSSystemDLL = GetModuleHandleW(&sRGSSSystemFilePath[0]);

	if (_hRGSSSystemDLL == NULL) 
	{
		RSShowLastErrorMessage2(L"_hRGSSSystemDLL");
		return;
	}

	_modules = new RGSSFunctions();

#define GETPROC(MODULE_NAME) \
	_modules->_p##MODULE_NAME = (MODULE_NAME##Proto)GetProcAddress(_hRGSSSystemDLL, #MODULE_NAME); \
	if(_modules->_p##MODULE_NAME == NULL) { \
		RSShowLastErrorMessage(); \
		return; \
	}

	GETPROC(RGSSEval);
	GETPROC(RGSSGetInt);
	GETPROC(RGSSGetBool);
	
	if (sRGSSSystemFilePath == L"System\\RGSS301.dll") {
		Keys.isRGSS3 = TRUE;
		GETPROC(RGSSSetStringUTF16);
		GETPROC(RGSSGetStringUTF16);
	}

	GETPROC(RGSSSetStringUTF8);
	GETPROC(RGSSGetStringUTF8);
	GETPROC(RGSSSetString);

	// 유니코드 환경인지 확인한다.
	if (IsWindowUnicode(RGSSPlayer)) 
	{
		int nArgs = 0;
		BOOL isConsole = FALSE;
		BOOL isTestMode = FALSE;

		// 프로그램의 명령행 옵션을 확인한다.
		LPWSTR* szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);

		if (szArglist != NULL) 
		{
			for (i = 0; i < nArgs; i++) 
			{
				if (lstrcmp(szArglist[i], L"console") == 0)
					isConsole = TRUE;

				if (lstrcmp(szArglist[i], L"test") == 0)
					isTestMode = TRUE;
			}
		}

		// 콘솔이 실행 중일 때만 리다이렉션
		if (isConsole) 
		{
			FILE* dummyFile;
			freopen_s(&dummyFile, "CONOUT$", "w", stdout);
		}

	}

	// C++ STL은 다음 함수를 호출하여 지역화 선언을 하지 않으면 문자열 셋 변환이 불가능하다.
	setlocale(LC_ALL, "");

#undef GETPROC

}

void rgss_remove_input()
{
	Keys.buf.clear();
	Keys.immutableTexts.clear();
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

void add_new_char(TCHAR wch)
{
	if (Keys.is_valid_character((int)wch) == TRUE) {
		lstrcat(&Keys.buf[0], &wch);
	}
}

void add_new_string(TCHAR* wstr)
{
	int i;
	int max = lstrlen(wstr);

	if (Keys.isNewLine) {
		Keys.buf.clear();
		Keys.immutableTexts.clear();
		Keys.isNewLine = FALSE;
	}

	int size = lstrlen(wstr);
	Keys.buf = wstr;

	// NULL 문자를 제거해야 정상적으로 표시된다.
	Keys.buf.resize(1);
}

void add_new_string2(char* wstr) 
{
	wchar_t* str = const_cast<wchar_t*>(ToUTF16(wstr));
	add_new_string(str);
}

void add_new_string3(TCHAR* wstr)
{
	if (Keys.isNewLine) {
		Keys.buf.clear();
		Keys.immutableTexts.clear();
		Keys.isNewLine = FALSE;
	}

	for (int i = 0; i < lstrlen(wstr); i++) {
		if (Keys.is_valid_character((int)wstr[i])) {
			Keys.immutableTexts += wstr[i];
		}
	}
}

void remove_last_char()
{
	size_t len = Keys.buf.length();

	if (!Keys.buf.empty())
	{
		Keys.buf.erase(len - 1, 1);
	}
}

void on_ime_context(WPARAM wParam)
{
	// RGSS Player가 포커스를 잃었을 때, 저장된 조합 중인 버퍼를 제거한다
	if (wParam == FALSE) 
	{
		Keys.buf.clear();
	}
}

void ime_composition_pipe1(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	int keycode = wParam;
	TCHAR szChar[2] = { 0, };

	szChar[0] = keycode;
	szChar[1] = 0;

	add_new_string3(szChar);

	// 조합 중인 한글 문자열을 삭제한다.
	Keys.buf.clear();

	Keys.bComp = FALSE;
}

/**
 * 글자가 조합되면 GCS_COMPSTR가 가장 먼저 발생되고,
 * 다음 글자가 입력되었을 때 이전 글자의 조합이 완료되면,
 * GCS_RESULTSTR가 발생하고 WM_IME_CHAR와 WM_IME_COMPOSITION이 발생한다.
 * 
 * WM_IME_CHAR에는 하나의 완성된 문자만 포함되며,
 * WM_IME_COMPOSITION은 조합 중인 문자도 포함된다.
 */
void ime_composition_pipe2(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	Keys.hImc = ImmGetContext(hWnd);

	// 조합 중인 문자열을 가지고 온다.
	int len;
	if (lParam & GCS_COMPSTR)
		len = ImmGetCompositionString(Keys.hImc, GCS_COMPSTR, NULL, 0);
	else if((lParam & GCS_RESULTSTR))
		len = ImmGetCompositionString(Keys.hImc, GCS_RESULTSTR, NULL, 0);

	if (len < 0) {
		ImmReleaseContext(hWnd, Keys.hImc);
		return;
	}

	TCHAR *szComp = new TCHAR[len + 1];
	memset(szComp, 0x00, len + 1);

	if (lParam & GCS_COMPSTR)
		ImmGetCompositionString(Keys.hImc, GCS_COMPSTR, szComp, len);
	else if ((lParam & GCS_RESULTSTR))
		ImmGetCompositionString(Keys.hImc, GCS_RESULTSTR, szComp, len);

	szComp[len] = 0;

	if ((lParam & GCS_COMPSTR))
	{
		// 이전 글자를 지우고 새로 갱신해야 한다.
		if (Keys.bComp) {
			// 한 글자의 조립이 끝났다는 게 정확하지 않다.
			while (Keys.counter > 0) {
				remove_last_char();
				Keys.counter--;
			}
		}

		if (len > 0) {
			add_new_string(szComp);
			Keys.counter++;
			Keys.bComp = TRUE;

		} else {
			Keys.bComp = FALSE;
		}
	}
	else if ((lParam & GCS_RESULTSTR)) {

	}

	delete[] szComp;
	ImmReleaseContext(hWnd, Keys.hImc);
}

void ime_composition_pipe3(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{	
	BOOL bFlag = FALSE;

	if (IsWindowUnicode(hWnd)) {

		// WBCS
		TCHAR szChar[2];
		szChar[0] = (TCHAR)wParam;
		szChar[1] = 0;

		add_new_string3(szChar);
		Keys.request_remove = TRUE;

	} else {
		// DBCS
		char szChar[3] = { 0, };

		if (IsDBCSLeadByte((BYTE)(wParam >> 8))) {

			szChar[0] = HIBYTE(LOWORD(wParam));
			szChar[1] = LOBYTE(LOWORD(wParam));
			szChar[2] = 0;
			bFlag = TRUE;
		}
		else {

			szChar[0] = (BYTE)wParam;
			szChar[1] = 0;
			bFlag = FALSE;
		}

		// 조립 중이므로 이전 글자를 지운다.
		// FALSE이면, 조립 완료 또는 영문 입력
		if (Keys.bComp) {
			remove_last_char();
			remove_last_char();
		}

		add_new_string2(szChar);
	}

	Keys.bComp = FALSE;
}

void update_composition_text(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (Keys.immutableTexts.size() > 0 || Keys.buf.size() > 0) {
		
		std::wstring retTexts = Keys.immutableTexts;
		retTexts.append(Keys.buf);

		if (Keys.isRGSS3 == TRUE) {
			_modules->_pRGSSSetStringUTF16("$input_char", &retTexts[0]);
		}
		else {
			_modules->_pRGSSSetStringUTF8("$input_char", ToUTF8(&retTexts[0]).c_str());
		}
	}
	else {
		_modules->_pRGSSSetStringUTF8("$input_char", ToUTF8(L"").c_str());
	}
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

	Keys.buf.clear();
	Keys.immutableTexts.clear();

}

RSDLL int is_any_key_down()
{
	int i;

	for (i = 0; i < MAX_KEYS; i++)
	{
		if (Keys.down[i] == TRUE)
		{
			return TRUE;
		}
	}

	return FALSE;
}

RSDLL BOOL is_composing()
{
	return Keys.bComp;
}

/**
 * CP_ACP (MBCS)  -> UTF16
 */
const wchar_t* ToUTF16(const char* raw) 
{
	int nLength = MultiByteToWideChar(CP_ACP, NULL, raw, -1, NULL, NULL);

	wchar_t* pBuf = new wchar_t[nLength + 1];

	MultiByteToWideChar(CP_ACP, 0, raw, lstrlenA(raw), pBuf, nLength);

	return pBuf;
}

std::string ToUTF8(const std::wstring &wstr)
{
	int len = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], static_cast<int>(wstr.size()), NULL, 0, NULL, NULL);
	std::string str(len, 0);
	WideCharToMultiByte(CP_UTF8, 0, &wstr[0], static_cast<int>(wstr.size()), &str[0], len, NULL, NULL);
	
	return str;
}

RSDLL const char* get_text()
{
	const char* pBuf = ToUTF8(&Keys.buf[0]).c_str();

	return pBuf;
}