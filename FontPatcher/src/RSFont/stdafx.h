// stdafx.h : ���� ��������� ���� ��������� �ʴ�
// ǥ�� �ý��� ���� ���� �Ǵ� ������Ʈ ���� ���� ������
// ��� �ִ� ���� �����Դϴ�.
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // ���� ������ �ʴ� ������ Windows ������� �����մϴ�.
// Windows ��� ����:
#include <windows.h>

//#define USE_UTF16

extern "C" {
	typedef int(*RGSSEvalProto)(const char*);
	typedef int(*RGSSSetStringUTF16Proto)(const char*, const wchar_t*);
	typedef const wchar_t*(*RGSSGetStringUTF16Proto)(const char*);
	typedef int(*RGSSSetStringUTF8Proto)(const char*, const char*);
	typedef const char*(*RGSSGetStringUTF8Proto)(const char*);
	typedef int(*RGSSGetIntProto)(const char*);
	typedef BOOL(*RGSSGetBoolProto)(const char*);
}

// TODO: ���α׷��� �ʿ��� �߰� ����� ���⿡�� �����մϴ�.

int RGSSInit(DWORD threadId);

