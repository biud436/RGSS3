#include "App.h"
#include <TlHelp32.h>
#include <tchar.h>
#include <cstdio>
#include <cstdlib>
#include <locale.h>
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

	// Enumerate the font families to callback
	hdc = GetDC(hWnd);
	EnumFontFamilies(hdc, NULL, (FONTENUMPROC)EnumFamCallBack, (LPARAM)NULL);
	ReleaseDC(hWnd, hdc);

	// Add the list to ComboBox
	SendMessage(m_hCombo, CB_RESETCONTENT, 0, 0);
	for (int i = 0; i<num; i++) {
		SendMessage(m_hCombo, CB_ADDSTRING, 0, (LPARAM)&logfont[i]);
	}

	SetComboBoxIndex(0);

	m_hSizeCombo = CreateWindow(TEXT("combobox"), NULL, WS_CHILD | WS_VISIBLE | CBS_DROPDOWNLIST | WS_VSCROLL | CBS_OWNERDRAWFIXED,
		100, DEFAULT_COMBO_HEIGHT + PAD, GetWindowWidth() - 100, 200, hWnd, (HMENU)ID_SIZE_COMBOBOX, m_hInst, NULL);

	SendMessage(m_hSizeCombo, CB_RESETCONTENT, 0, 0);
	for (int i = 0; i<33; i++) {
		SendMessage(m_hSizeCombo, CB_ADDSTRING, 0, (LPARAM)g_fontSizeTable[i]);
	}
	SendMessage(m_hSizeCombo, CB_SETCURSEL, 8, 0);
	
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
		TCHAR szTextSize[64];
		snprintf(szTextSize, 64, "%d", g_fontSizeTable[lpdis->itemID]);

		TextOut(lpdis->hDC,
			lpdis->rcItem.left + 5,
			lpdis->rcItem.top + 2,
			szTextSize,
			lstrlen(szTextSize)
		);
	}

		break;
	}


}

void App::OnPaint(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam) {
	HDC hdc;
	PAINTSTRUCT ps;
	TCHAR str[128];
	TCHAR szFontText[128];
	TCHAR iniDir[MAX_PATH];
	TCHAR szFontSize[64];
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

		// Clear the rect
		FillRect(hdc, &backRt, (HBRUSH)WHITE_BRUSH);

		TCHAR szFontFace[64];
		GetTextFaceA(hdc, 64, szFontFace);

		// Draw the text
		wsprintf(str, TEXT("%s"), szFontFace);
		/*wsprintf(str, TEXT("%s"), m_tmpFont.lfFaceName);*/
		DrawText(hdc, str, lstrlen(str), &rt,DT_CENTER);

		// Copy the path
		GetCurrentDirectory(MAX_PATH, iniDir);
		_tcsncat_s(iniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

		// Change the Game.ini file
		WritePrivateProfileString(_T("Game"), _T("Font"), m_tmpFont.lfFaceName, iniDir);

		_snprintf(szFontSize, 64, "%d", nFontHeight);
		WritePrivateProfileString(_T("Game"), _T("FontSize"), szFontSize, iniDir);

		// Select the system font.
		SelectObject(hdc, m_oldfont);

		// Draw the font text section
		lstrcpy(szFontText, "FONT : ");
		GetTextExtentPoint32(hdc, szFontText, lstrlen(szFontText), &sz);
		TextOut(hdc, DEFAULT_COMBO_WIDTH / 2 - sz.cx / 2, DEFAULT_COMBO_HEIGHT / 2 - sz.cy / 2, szFontText, lstrlen(szFontText));

		// Draw the font size section
		lstrcpy(szFontText, "SIZE : ");
		GetTextExtentPoint32(hdc, szFontText, lstrlen(szFontText), &sz);
		TextOut(hdc, DEFAULT_COMBO_WIDTH / 2 - sz.cx / 2, PAD + DEFAULT_COMBO_HEIGHT + DEFAULT_COMBO_HEIGHT / 2 - sz.cy / 2, szFontText, lstrlen(szFontText));

		DeleteObject(m_font);
	}

	EndPaint(hWnd, &ps);
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

int App::GetComboBoxIndex() const
{
	return m_nComboIndex;
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