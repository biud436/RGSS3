// RSFont.cpp : DLL 응용 프로그램을 위해 내보낸 함수를 정의합니다.
//

#include "stdafx.h"

#include <tchar.h>
#include <cstdlib>
#include <cstdio>

RGSSEvalProto gRGSSEval;
RGSSSetStringUTF16Proto gRGSSSetStringUTF16;
HMODULE g_hRGSSSystemDLL;

int g_nInit = 0;

const wchar_t* AllocWideChar(const char* law)
{
	int length = MultiByteToWideChar(CP_UTF8, 0, law, -1, NULL, 0);

	if (length == 0)
	{
		return L"";
	}

	// NULL 문자를 포함하여 메모리를 초기화 않으면 오류가 난다.
	LPWSTR lpszWideChar = new WCHAR[length + 1];

	if (lpszWideChar == NULL)
	{
		return L"";
	}

	memset(lpszWideChar, 0, sizeof(WCHAR) * (length + 1));
	int ret = MultiByteToWideChar(CP_UTF8, 0, law, -1, lpszWideChar, length);

	if (ret == 0)
	{
		return L"";
	}

	return lpszWideChar;
}

const char* AllocMultibyteChar(const wchar_t* law)
{
	int length = WideCharToMultiByte(CP_UTF8, 0, law, -1, NULL, 0, NULL, NULL);

	if (length == 0)
	{
		return "";
	}

	// NULL 문자를 포함하여 메모리를 초기화 않으면 오류가 난다.
	LPSTR lpszChar = new char[length + 1];

	if (lpszChar == NULL)
	{
		return "";
	}

	memset(lpszChar, 0, sizeof(char) * (length + 1));
	int ret = WideCharToMultiByte(CP_UTF8, 0, law, -1, lpszChar, length, NULL, NULL);

	if (ret == 0)
	{
		return "";
	}

	return lpszChar;
}

const char* Conv(const char* law)
{
	const wchar_t* from = AllocWideChar(law);
	const char* to = AllocMultibyteChar(from);
	
	return to;
}

void RGSSInit()
{

	TCHAR RGSSSystemFilePath[MAX_PATH];
	TCHAR IniDir[MAX_PATH];
	WCHAR FontName[MAX_PATH];
	TCHAR FontSize[MAX_PATH];

	char szFontName[MAX_PATH];

	GetCurrentDirectory(MAX_PATH, IniDir);
	_tcsncat_s(IniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

	GetPrivateProfileString(_T("Game"), _T("Library"), _T("System/RGSS301.dll"), RGSSSystemFilePath, MAX_PATH, IniDir);
	GetPrivateProfileStringW(L"Game", L"Font", L"나눔고딕", FontName, MAX_PATH, AllocWideChar(IniDir));
	GetPrivateProfileString(_T("Game"), _T("FontSize"), _T("16"), FontSize, MAX_PATH, IniDir);

	g_hRGSSSystemDLL = GetModuleHandle(RGSSSystemFilePath);

	gRGSSEval = (RGSSEvalProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSEval");
	gRGSSSetStringUTF16 = (RGSSSetStringUTF16Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSSetStringUTF16");

	Sleep(20);

	if (gRGSSEval != NULL) {
		
		gRGSSSetStringUTF16("$font_name", FontName);

		snprintf(szFontName, MAX_PATH, "Font.default_name = [$font_name]");
		gRGSSEval(Conv(szFontName));
		snprintf(szFontName, MAX_PATH, "Font.default_size = %s", FontSize);
		gRGSSEval(szFontName);

	}

}

