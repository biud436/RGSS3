#ifndef _APP_H__
#define _APP_H__

#define WIN32_LEAN_AND_MEAN

#include <Windows.h>

class App
{
public:
	App(HINSTANCE inst);
	~App();

	// Create the app
	void OnCreate(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);

	// Draw the item with ComboBox
	void OnComboItem(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);

	// Draw the app
	void OnPaint(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);

	// Default the window proc
	LRESULT CallProc(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);

	// DLL Inject function
	BOOL InjectDll2(LPCTSTR szDllPath);

	void ShowErrorMessage();

public:

	int GetComboBoxIndex() const;
	void SetComboBoxIndex(int index);

	int GetWindowWidth() const;
	int GetWindowHeight() const;

protected:

	HINSTANCE m_hInst;

	HWND m_hWnd;
	HWND m_hBtnOK;
	HWND m_hCombo;
	HWND m_hSizeCombo;

	LOGFONT m_tmpFont;
	HFONT m_font, m_oldfont;
	int m_nComboIndex;

	BOOL m_bResult;

	BOOL m_bInit;

};

#endif