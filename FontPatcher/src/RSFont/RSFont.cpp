// RSFont.cpp : DLL 응용 프로그램을 위해 내보낸 함수를 정의합니다.
//

#include "stdafx.h"

#include <tchar.h>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <string>
#include <process.h>
#include <TlHelp32.h>

// 함수 포인터
RGSSEvalProto gRGSSEval;
RGSSSetStringUTF16Proto gRGSSSetStringUTF16;
RGSSGetStringUTF16Proto gRGSSGetStringUTF16;
RGSSGetIntProto gRGSSGetInt;
RGSSGetBoolProto gRGSSGetBool;

// 함수 전방 선언
VOID CALLBACK APCProc(ULONG_PTR);

// 핸들
HMODULE g_hRGSSSystemDLL;

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

int RGSSInit(DWORD threadId)
{
	TCHAR RGSSSystemFilePath[MAX_PATH];
	TCHAR IniDir[MAX_PATH];
	WCHAR FontName[MAX_PATH];
	TCHAR FontSize[MAX_PATH];

	GetCurrentDirectory(MAX_PATH, IniDir);
	_tcsncat_s(IniDir, MAX_PATH, _T("\\Game.ini"), MAX_PATH);

	GetPrivateProfileString(_T("Game"), _T("Library"), _T("System/RGSS301.dll"), RGSSSystemFilePath, MAX_PATH, IniDir);
	GetPrivateProfileStringW(L"Game", L"Font", L"나눔고딕", FontName, MAX_PATH, AllocWideChar(IniDir));
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
		
	// C언어의 wchar_t* 타입과 같다.
	gRGSSSetStringUTF16("$font_name", FontName);

	int nValidId = gRGSSGetInt("Game_BattlerBase::FEATURE_ELEMENT_RATE");

	// 폰트 크기를 설정한다.
	std::ostringstream oss;
	oss << "Font.default_size = " << FontSize;
	std::string sFontSize = oss.str();

	// 폰트 명을 설정한다.
	gRGSSEval("Font.default_name = [$font_name]");
	gRGSSEval(sFontSize.c_str());

	// Game_BattlerBase::FEATURE_ELEMENT_RATE가 0이면 아직 스크립트 로드가 덜된 것으로 추측한다.
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