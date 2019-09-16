// RSFont.cpp : DLL ���� ���α׷��� ���� ������ �Լ��� �����մϴ�.
//

#include "stdafx.h"

#include <tchar.h>
#include <cstdlib>
#include <cstdio>

RGSSEvalProto gRGSSEval;
HMODULE g_hRGSSSystemDLL;

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

	snprintf(szFontName, MAX_PATH, "Font.default_name = \"%s\"", FontName);
	snprintf(szFontName, MAX_PATH, "Font.default_size = %s", FontSize);

	if (gRGSSEval != NULL) {
		gRGSSEval(szFontName);
	}
}