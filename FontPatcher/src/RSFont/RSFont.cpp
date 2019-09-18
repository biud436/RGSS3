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
RGSSSetStringUTF8Proto gRGSSSetStringUTF8;
RGSSGetStringUTF8Proto gRGSSGetStringUTF8;
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

std::string ToUTF8(const std::wstring& law)
{
	int length = WideCharToMultiByte(CP_UTF8, 0, law.c_str(), -1, NULL, 0, NULL, NULL);

	if (length == 0)
	{
		return "";
	}

	std::string utf8(length + 1, 0);

	if (&utf8[0] == NULL)
	{
		return "";
	}

	int ret = WideCharToMultiByte(CP_UTF8, 0, law.c_str(), -1, &utf8[0], length + 1, NULL, NULL);

	if (ret == 0)
	{
		return "";
	}

	return utf8;
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

	gRGSSGetInt = (RGSSGetIntProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetInt");
	gRGSSGetBool = (RGSSGetBoolProto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetBool");

	Sleep(20);

	if (gRGSSEval == NULL) 
	{
		return -1;
	}

	// These function doesn't exist in the RPG Maker XP.
	// so it needs the new logic to convert a string in UTF16 to UTF8.
#ifdef USE_UTF16
	gRGSSSetStringUTF16 = (RGSSSetStringUTF16Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSSetStringUTF16");
	gRGSSGetStringUTF16 = (RGSSGetStringUTF16Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetStringUTF16");
#else
	gRGSSSetStringUTF8 = (RGSSSetStringUTF8Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSSetStringUTF8");
	gRGSSGetStringUTF8 = (RGSSGetStringUTF8Proto)GetProcAddress(g_hRGSSSystemDLL, "RGSSGetStringUTF8");
#endif

	HANDLE hThread = GetCurrentThread();
		
	// C����� wchar_t* Ÿ�԰� ����.
#ifdef USE_UTF16
	gRGSSSetStringUTF16("$font_name", FontName);
#else
	gRGSSSetStringUTF8(ToUTF8(L"$font_name").c_str(), ToUTF8(FontName).c_str());
#endif

	std::string sRubyVersion = gRGSSGetStringUTF8("RUBY_VERSION");
	
	int	nValidId = 0;

	if (sRubyVersion == "1.9.2") {
		nValidId = gRGSSGetInt("Game_BattlerBase::FEATURE_ELEMENT_RATE");
	}
	else {
		nValidId = gRGSSGetInt("Input::DOWN");
	}

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

	std::string sRubyVersion = gRGSSGetStringUTF8("RUBY_VERSION");

	if (sRubyVersion == "1.9.2") {
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

}