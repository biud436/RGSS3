#include "App.h"
#include <TlHelp32.h>
#include <tchar.h>
#include <cstdio>
#include <cstdlib>
#include <locale.h>
#include <sstream>
#include "constants.h"

LOGFONT logfont[MAX_FONT];
int num = 0;

const int g_fontSizeTable[33] = { 8, 10, 12, 14,
						16, 18, 20, 22,
						24, 26, 28, 30,
						32, 34, 36, 38,
						40, 42, 44, 46,
						48, 50, 52, 54,
						56, 58, 60, 62,
						64, 66, 68, 70, 72
};

App::App(HINSTANCE inst) :
	m_hInst(inst),
	m_hWnd(NULL),
	m_hBtnOK(NULL),
	m_hCombo(NULL),
	m_hSizeCombo(NULL),
	m_hLabel1(NULL),
	m_hLabel2(NULL),
	m_font(NULL),
	m_oldfont(NULL),
	m_nComboIndex(-1),
	m_bResult(FALSE),
	m_bInit(FALSE)
{

}

App::~App()
{
}

LRESULT App::CallProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	LPMEASUREITEMSTRUCT lpmis;

	switch (iMessage) {
	case WM_CREATE:
		OnCreate(hWnd, iMessage, wParam, lParam);
		return 0;
	case WM_COMMAND:
		switch (LOWORD(wParam)) {
		case ID_EXECUTE:
			InjectDll2(DEF_DLL_NAME);
			break;
		case ID_COMBOBOX:
		case ID_SIZE_COMBOBOX:
			switch (HIWORD(wParam)) {
			case CBN_SELCHANGE:
				InvalidateRect(hWnd, NULL, TRUE);
				return 0;
			}
			break;
		}
		return 0;

	case WM_MEASUREITEM:
		lpmis = (LPMEASUREITEMSTRUCT)lParam;
		lpmis->itemHeight = 30;
		return TRUE;
	case WM_DRAWITEM:
		OnComboItem(hWnd, iMessage, wParam, lParam);
		return 0;
	case WM_PAINT:
		OnPaint(hWnd, iMessage, wParam, lParam);
		return 0;
	case WM_DESTROY:
		OnExit(hWnd, iMessage, wParam, lParam);
		PostQuitMessage(0);
		return 0;
	}
	return(DefWindowProc(hWnd, iMessage, wParam, lParam));
}

int CALLBACK EnumFamCallBack(ENUMLOGFONT FAR *lpelf, NEWTEXTMETRIC FAR *lpntm,
	int FontType, LPARAM lParam)
{
	if (num < MAX_FONT) {
		logfont[num] = lpelf->elfLogFont;
		num++;
		return TRUE;
	}
	else {
		return FALSE;
	}
}

void App::OnCreate(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam) {
	m_hWnd = hWnd;
	HDC hdc;

	// Craete the button
	m_hBtnOK = CreateWindow(TEXT("button"), TEXT("Run"), BUTTON_STYLE, 0, GetWindowHeight() - 64, GetWindowWidth(), 64, hWnd, (HMENU)ID_EXECUTE, m_hInst, NULL);

	// Create the ComboBox
	m_hCombo = CreateWindow(TEXT("combobox"), NULL, WS_CHILD | WS_VISIBLE | CBS_DROPDOWNLIST | WS_VSCROLL | CBS_OWNERDRAWFIXED,
		100, 0, GetWindowWidth() - 100, 200, hWnd, (HMENU)ID_COMBOBOX, m_hInst, NULL);

	// Create Static Control
	m_hLabel1 = CreateWindow(TEXT("static"), "Font : ", WS_CHILD | WS_VISIBLE | SS_CENTER, 0, 16 - 12 / 2, 100, 32, hWnd, (HMENU)ID_LABEL1, m_hInst, NULL);

	// Enumerate the font families to callback
	hdc = GetDC(hWnd);
	EnumFontFamilies(hdc, NULL, (FONTENUMPROC)EnumFamCallBack, (LPARAM)NULL);
	ReleaseDC(hWnd, hdc);

	// Add the list to ComboBox
	SendMessage(m_hCombo, CB_RESETCONTENT, 0, 0);
	for (int i = 0; i<num; i++) {
		SendMessage(m_hCombo, CB_ADDSTRING, 0, (LPARAM)&logfont[i]);
	}

	const int fontIndex = GetInt(TEXT("FontIndex"));

	SetComboBoxIndex(fontIndex);

	// Create the ComboBox
	m_hSizeCombo = CreateWindow(TEXT("combobox"), NULL, WS_CHILD | WS_VISIBLE | CBS_DROPDOWNLIST | WS_VSCROLL | CBS_OWNERDRAWFIXED,
		100, DEFAULT_COMBO_HEIGHT + PAD, GetWindowWidth() - 100, 200, hWnd, (HMENU)ID_SIZE_COMBOBOX, m_hInst, NULL);

	// Create Static Control
	m_hLabel2 = CreateWindow(TEXT("static"), "Size : ", WS_CHILD | WS_VISIBLE | SS_CENTER, 0, 32 + 10 + 16 - 12 / 2, 100, 32, hWnd, (HMENU)ID_LABEL2, m_hInst, NULL);

	SendMessage(m_hSizeCombo, CB_RESETCONTENT, 0, 0);
	for (int i = 0; i<33; i++) {
		SendMessage(m_hSizeCombo, CB_ADDSTRING, 0, (LPARAM)g_fontSizeTable[i]);
	}

	const int fontCount = GetInt(TEXT("FontCount"));
	int fontSizeIndex = GetInt(TEXT("FontSizeIndex"));
	if (fontCount == 0) {
		fontSizeIndex = 8;
	}

	SendMessage(m_hSizeCombo, CB_SETCURSEL, fontSizeIndex, 0);
	
}

TString App::GetString(TString key)
{
	TCHAR lpszIniFile[MAX_PATH];
	TCHAR lpszValue[MAX_PATH];

	std::stringstream ss;

	GetCurrentDirectory(MAX_PATH, lpszIniFile);
	ss << lpszIniFile << "\\Game.ini";
	TString sIniFile = ss.str();

	GetPrivateProfileString(_T("Game"), &key[0], TEXT(""), lpszValue, MAX_PATH, &sIniFile[0]);

	TString sRetText = lpszValue;

	return sRetText;
}

const int App::GetInt(TString key)
{
	std::string sRet = GetString(key);
	int ret = 0;

	if (sRet != "") {
		ret = std::stoi(sRet);
	}

	return ret;
}

BOOL App::WriteString(TString key, TString value)
{
	TCHAR lpszIniFile[MAX_PATH];

	std::stringstream ss;

	GetCurrentDirectory(MAX_PATH, lpszIniFile);
	ss << lpszIniFile << "\\Game.ini";
	std::string sIniFile = ss.str();

	BOOL ret = WritePrivateProfileString(_T("Game"), &key[0], &value[0], &sIniFile[0]);

	return ret;
}

BOOL App::WriteInt(TString key, const int value)
{
	TCHAR lpszIniFile[MAX_PATH];

	std::stringstream ss;

	GetCurrentDirectory(MAX_PATH, lpszIniFile);
	ss << lpszIniFile << "\\Game.ini";
	std::string sIniFile = ss.str();

	ss.str("");
	ss << value;

	BOOL ret = WritePrivateProfileString(_T("Game"), &key[0], &ss.str()[0], &sIniFile[0]);

	return ret;
}


std::string App::ToString(int value)
{
	std::ostringstream oss;
	oss << value;

	return oss.str();
}

void App::OnComboItem(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	LPDRAWITEMSTRUCT lpdis;
	HBRUSH bkBrush;

	lpdis = (LPDRAWITEMSTRUCT)lParam;

	// if it is selected the certain item of the combobox?
	if (lpdis->itemState & ODS_SELECTED) {
		// Select with the blue color.
		bkBrush = GetSysColorBrush(COLOR_HIGHLIGHT);
		SetBkColor(lpdis->hDC, GetSysColor(COLOR_HIGHLIGHT));
		SetTextColor(lpdis->hDC, GetSysColor(COLOR_WINDOW));
	}
	else {
		bkBrush = GetSysColorBrush(COLOR_WINDOW);
		SetBkColor(lpdis->hDC, GetSysColor(COLOR_WINDOW));
		SetTextColor(lpdis->hDC, GetSysColor(COLOR_WINDOWTEXT));
	}
	FillRect(lpdis->hDC, &lpdis->rcItem, bkBrush);

	switch (wParam) {
	case ID_COMBOBOX: 
	{
		// Change the font instead of using system font.
		m_tmpFont = logfont[lpdis->itemID];
		m_tmpFont.lfHeight = 25;
		m_tmpFont.lfWidth = 0;
		m_font = CreateFontIndirect(&m_tmpFont);
		m_oldfont = (HFONT)SelectObject(lpdis->hDC, m_font);

		// Draw the text into the font combo-box.
		TextOut(lpdis->hDC,
			lpdis->rcItem.left + 5,
			lpdis->rcItem.top + 2,
			logfont[lpdis->itemID].lfFaceName,
			lstrlen(logfont[lpdis->itemID].lfFaceName)
		);

		// Select the system font.
		SelectObject(lpdis->hDC, m_oldfont);
		DeleteObject(m_font);
	}
	break;
	case ID_SIZE_COMBOBOX: {

		TString sTextSize = ToString(g_fontSizeTable[lpdis->itemID]);

		TextOut(lpdis->hDC,
			lpdis->rcItem.left + 5,
			lpdis->rcItem.top + 2,
			sTextSize.c_str(),
			sTextSize.size()
		);
	}

		break;
	}


}

void App::OnPaint(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam) 
{
	HDC hdc;
	PAINTSTRUCT ps;
	TCHAR iniDir[MAX_PATH];
	SIZE sz = { 0 };

	hdc = BeginPaint(hWnd, &ps);

	m_nComboIndex = SendMessage(m_hCombo, CB_GETCURSEL, 0, 0);

	if (m_nComboIndex != -1) {

		int iComboIndex = SendMessage(m_hSizeCombo, CB_GETCURSEL, 0, 0);
		
		if (iComboIndex == -1)
			iComboIndex = 0;

		int nFontHeight = g_fontSizeTable[iComboIndex];
		
		// Select the font from log font.
		m_tmpFont = logfont[m_nComboIndex];
		m_tmpFont.lfHeight = nFontHeight;
		m_tmpFont.lfWidth = 0;
		m_font = CreateFontIndirect(&m_tmpFont);
		m_oldfont = (HFONT)SelectObject(hdc, m_font);

		// Specify the rect
		RECT rt = { 0, };
		RECT backRt = { 0, };
		const int h = GetWindowHeight() - 100;

		SetRect(&rt, 10, 200, GetWindowWidth(), h);
		SetRect(&backRt, 0, 180, GetWindowWidth(), h);

		// Draw the text
		SetBkMode(hdc, TRANSPARENT);
		DrawText(hdc, m_tmpFont.lfFaceName, lstrlen(m_tmpFont.lfFaceName), &rt, DT_CENTER| DT_VCENTER);

		// Copy the path
		GetCurrentDirectory(MAX_PATH, iniDir);
		_tcsncat_s(iniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH); // it is possible to replace with std::ostringstream

		// Change the Game.ini file
		WritePrivateProfileString(_T("Game"), _T("Font"), m_tmpFont.lfFaceName, iniDir);

		TString sFontSize = ToString(nFontHeight);
		WritePrivateProfileString(_T("Game"), _T("FontSize"), sFontSize.c_str(), iniDir);

		// Select the system font.
		SelectObject(hdc, m_oldfont);

		DeleteObject(m_font);
	}

	EndPaint(hWnd, &ps);
}

void App::OnExit(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	const int fontIndex = SendMessage(m_hCombo, CB_GETCURSEL, 0, 0);
	const int sizeIndex = SendMessage(m_hSizeCombo, CB_GETCURSEL, 0, 0);
	const int numberOfFonts = SendMessage(m_hCombo, CB_GETCOUNT, 0, 0);

	WriteInt(TEXT("FontIndex"), fontIndex);
	WriteInt(TEXT("FontSizeIndex"), sizeIndex);
	WriteInt(TEXT("FontCount"), numberOfFonts);
}


BOOL App::InjectDll2(LPCTSTR szDllPath)
{
	if (m_bInit) {
		MessageBox(m_hWnd, "The program is still in use.", _T(""), MB_OK);
		return FALSE;
	}

	HANDLE hProcess = INVALID_HANDLE_VALUE;
	HANDLE hThread = NULL;
	HMODULE hMod = NULL;
	LPVOID pRemoteBuf = NULL;
	DWORD dwBufSize = (DWORD)(_tcslen(szDllPath) + 1) * sizeof(TCHAR);
	LPTHREAD_START_ROUTINE pThreadProc;

	STARTUPINFO si = { sizeof(STARTUPINFO), };
	PROCESS_INFORMATION pi = { 0 };

	m_bResult = CreateProcess(NULL,
		DEF_PROCESS_NAME,
		NULL,
		NULL,
		FALSE,
		0,
		NULL,
		NULL,
		&si,
		&pi);
	DWORD exitCode = 0;

	if (!m_bResult)
	{
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
		ShowErrorMessage();
		return FALSE;
	}

	WaitForInputIdle(pi.hProcess, INFINITE);

	m_bInit = TRUE;

	hProcess = pi.hProcess;

	pRemoteBuf = VirtualAllocEx(hProcess, NULL, dwBufSize, MEM_COMMIT, PAGE_READWRITE);

	if (pRemoteBuf == NULL) {
		return FALSE;
	}
		
	WriteProcessMemory(hProcess, pRemoteBuf, (LPVOID)szDllPath, dwBufSize, NULL);

	hMod = GetModuleHandleA(_T("Kernel32.dll"));
	pThreadProc = (LPTHREAD_START_ROUTINE)GetProcAddress(hMod, "LoadLibraryA");

	hThread = CreateRemoteThread(hProcess, NULL, 0, pThreadProc, pRemoteBuf, 0, NULL);

	WaitForSingleObject(hThread, INFINITE);

	VirtualFreeEx(hProcess, pRemoteBuf, 0, MEM_RELEASE);

	WaitForSingleObject(hProcess, INFINITE);

	m_bResult = GetExitCodeProcess(hProcess, &exitCode);

	CloseHandle(hProcess);
	CloseHandle(hThread);
	CloseHandle(pi.hThread);

	m_bInit = FALSE;

	if (!m_bResult) {
		ShowErrorMessage();
		return FALSE;
	}

	return TRUE;
}

void App::ShowErrorMessage()
{
	LPVOID lpMsgBuf;
	DWORD dw = GetLastError();
	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL, dw, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)&lpMsgBuf, 0, NULL);

	MessageBox(m_hWnd, (LPTSTR)lpMsgBuf, _T(""), MB_OK);

	LocalFree(lpMsgBuf);
}

void App::SetComboBoxIndex(int index)
{
	if (m_hCombo == NULL) return;
	SendMessage(m_hCombo, CB_SETCURSEL, index, 0);
}

int App::GetWindowWidth() const
{
	RECT rt = { 0, };
	GetClientRect(m_hWnd, &rt);
	return static_cast<int>(rt.right - rt.left);
}

int App::GetWindowHeight() const
{
	RECT rt = { 0, };
	GetClientRect(m_hWnd, &rt);
	return static_cast<int>(rt.bottom - rt.top);
}