// RSFont.cpp : DLL ���� ���α׷��� ���� ������ �Լ��� �����մϴ�.
//

#include "stdafx.h"

#include <tchar.h>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <string>
#include <process.h>
#include <TlHelp32.h>

// �Լ� ������
RGSSEvalProto gRGSSEval;
RGSSSetStringUTF16Proto gRGSSSetStringUTF16;
RGSSGetStringUTF16Proto gRGSSGetStringUTF16;
RGSSGetIntProto gRGSSGetInt;
RGSSGetBoolProto gRGSSGetBool;

// �Լ� ���� ����
VOID CALLBACK APCProc(ULONG_PTR);

// �ڵ�
HMODULE g_hRGSSSystemDLL;

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

int RGSSInit(DWORD threadId)
{
	TCHAR RGSSSystemFilePath[MAX_PATH];
	TCHAR IniDir[MAX_PATH];
	WCHAR FontName[MAX_PATH];
	TCHAR FontSize[MAX_PATH];

	GetCurrentDirectory(MAX_PATH, IniDir);
	_tcsncat_s(IniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

	GetPrivateProfileString(_T("Game"), _T("Library"), _T("System/RGSS301.dll"), RGSSSystemFilePath, MAX_PATH, IniDir);
	GetPrivateProfileStringW(L"Game", L"Font", L"�������", FontName, MAX_PATH, AllocWideChar(IniDir));
	GetPrivateProfileString(_T("Game"), _T("FontSize"), _T("16"), FontSize, MAX_PATH, IniDir);

	g_hRGSSSystemDLL = GetModuleHandle(RGSSSystemFilePath);

	if (g_hRGSSSystemDLL == NULL) {
		return -1;
	}

	gRGSSEval = (RGSSEvalProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSEval");
	gRGSSSetStringUTF16 = (RGSSSetStringUTF16Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSSetStringUTF16");
	gRGSSGetStringUTF16 = (RGSSGetStringUTF16Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetStringUTF16");
	gRGSSGetInt = (RGSSGetIntProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetInt");
	gRGSSGetBool = (RGSSGetBoolProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetBool");

	Sleep(20);

	if (gRGSSEval == NULL) 
	{
		return -1;
	}

	HANDLE hThread = GetCurrentThread();
		
	// C����� wchar_t* Ÿ�԰� ����.
	gRGSSSetStringUTF16("$font_name", FontName);

	int nValidId = gRGSSGetInt("Game_BattlerBase::FEATURE_ELEMENT_RATE");

	// ��Ʈ ũ�⸦ �����Ѵ�.
	std::ostringstream oss;
	oss << "Font.default_size = " << FontSize;
	std::string sFontSize = oss.str();

	// ��Ʈ ���� �����Ѵ�.
	gRGSSEval("Font.default_name = [$font_name]");
	gRGSSEval(sFontSize.c_str());

	// Game_BattlerBase::FEATURE_ELEMENT_RATE�� 0�̸� ���� ��ũ��Ʈ �ε尡 ���� ������ �����Ѵ�.
	if (nValidId == 0)
	{
		return -1;
	}

	// Set the font when using YEA-MessageSystem
	QueueUserAPC(APCProc, hThread, (ULONG_PTR)0);
	SleepEx(INFINITE, TRUE);

	return 0;

}

VOID CALLBACK APCProc(ULONG_PTR dwParam)
{
	std::ostringstream oss;

	oss << "$imported[" << "\"YEA-MessageSystem\"" << "]";
	std::string sValid = oss.str();

	BOOL isValid = gRGSSGetBool(sValid.c_str());

	if (isValid == TRUE) 
	{
		gRGSSEval("YEA::MESSAGE.const_set(:MESSAGE_WINDOW_FONT_NAME, Font.default_name)");
		gRGSSEval("YEA::MESSAGE.const_set(:MESSAGE_WINDOW_FONT_SIZE, Font.default_size)");
	}

}