#ifndef _APP_H__
#define _APP_H__

#define WIN32_LEAN_AND_MEAN

#include <Windows.h>
#include <string>

#ifdef _UNICODE 
using TString = std::wstring;
#else
using TString = std::string;
#endif

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

	// Exit EventHandler
	void OnExit(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam);

	void ShowErrorMessage();

public:

	int GetComboBoxIndex() const { 
		return m_nComboIndex; 
	}

	void SetComboBoxIndex(int index);

	int GetWindowWidth() const;
	int GetWindowHeight() const;

	TString ToString(int value);

	TString GetString(TString key);
	const int GetInt(TString key);
	BOOL WriteString(TString key, TString value);
	BOOL WriteInt(TString key, const int value);

protected:

	HINSTANCE m_hInst;

	HWND m_hWnd;
	HWND m_hBtnOK;
	HWND m_hCombo, m_hSizeCombo;
	HWND m_hLabel1, m_hLabel2;

	LOGFONT m_tmpFont;
	HFONT m_font, m_oldfont;
	int m_nComboIndex;

	BOOL m_bResult;

	BOOL m_bInit;

};

#endif