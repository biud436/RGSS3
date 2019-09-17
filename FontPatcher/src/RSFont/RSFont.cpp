// RSFont.cpp : DLL ���� ���α׷��� ���� ������ �Լ��� �����մϴ�.
//

#include "stdafx.h"

#include <tchar.h>
#include <cstdlib>
#include <cstdio>

RGSSEvalProto gRGSSEval;
HMODULE g_hRGSSSystemDLL;

int g_nInit = 0;

const wchar_t* AllocWideChar(const char* law)
{
	int length = MultiByteToWideChar(CP_UTF8, 0, law, -1, NULL, 0);

	if (length == 0)
	{
		return L"";
	}

	// NULL ���ڸ� �����Ͽ� �޸𸮸� �ʱ�ȭ ������ ������ ����.
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

	// NULL ���ڸ� �����Ͽ� �޸𸮸� �ʱ�ȭ ������ ������ ����.
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
	TCHAR FontName[MAX_PATH];
	TCHAR FontSize[MAX_PATH];

	char szFontName[MAX_PATH];

	GetCurrentDirectory(MAX_PATH, IniDir);
	_tcsncat_s(IniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

	GetPrivateProfileString(_T("Game"), _T("Library"), _T("System/RGSS301.dll"), RGSSSystemFilePath, MAX_PATH, IniDir);
	GetPrivateProfileString(_T("Game"), _T("Font"), _T("�������"), FontName, MAX_PATH, IniDir);
	GetPrivateProfileString(_T("Game"), _T("FontSize"), _T("16"), FontSize, MAX_PATH, IniDir);

	g_hRGSSSystemDLL = GetModuleHandle(RGSSSystemFilePath);

	gRGSSEval = (RGSSEvalProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSEval");

	Sleep(20);

	if (gRGSSEval != NULL) {
		snprintf(szFontName, MAX_PATH, "Font.default_name = [\"%s\"]", FontName);
		gRGSSEval(Conv(szFontName));
		snprintf(szFontName, MAX_PATH, "Font.default_size = %s", FontSize);
		gRGSSEval(Conv(szFontName));

	}

}

