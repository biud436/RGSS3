// stdafx.h : ���� ��������� ���� ��������� �ʴ�
// ǥ�� �ý��� ���� ���� �Ǵ� ������Ʈ ���� ���� ������
// ��� �ִ� ���� �����Դϴ�.
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // ���� ������ �ʴ� ������ Windows ������� �����մϴ�.
// Windows ��� ����:
#include <windows.h>

extern "C" {
	typedef int(*RGSSEvalProto)(const char*);
	typedef int(*RGSSSetStringUTF16Proto)(const char*, const wchar_t*);
}

// TODO: ���α׷��� �ʿ��� �߰� ����� ���⿡�� �����մϴ�.

void RGSSInit();

