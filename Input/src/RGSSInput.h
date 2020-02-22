#ifndef __RGSSINPUT_H__

#include "DLL.h"

const int MAX_KEYS = 255;
const int MAX_TEXT_BUFFS = 4096;

#pragma comment(lib,  "imm32.lib")

#ifdef __cplusplus
extern "C"
{
#endif 

typedef struct RGSSKeys {
	BYTE down[MAX_KEYS];
	BYTE pressed[MAX_KEYS];
	long mouseX;
	long mouseY;
	
	typedef struct Buttons {
		BOOL left;
		BOOL right;
		BOOL middle;
	} Buttons;
	
	Buttons buttons;

	HIMC hImc;
	BOOL bComp;
	
	TCHAR *szComp;
	TCHAR szChar[3];

#if defined(UNICODE) || defined(_UNICODE)
	std::wstring buf;
	std::wstring immutableTexts;
#else
	std::string buf;
	std::string immutableTexts;
#endif

	BOOL isRGSS3;

	BOOL isNewLine;
	BOOL isBackspace;
	BOOL request_remove;

	size_t counter;

	BOOL is_valid_character(int keycode);
	BOOL is_hangul_character(int keycode);

	DWORD last_status;

};

void rgss_input_init(HWND RGSSPlayer);
void rgss_remove_input();
void rgss_set_keydown(WPARAM wParam);
void rgss_set_keyup(WPARAM wParam);
void rgss_set_mousemove(LPARAM lParam);
void rgss_set_mouse_lbutton(BOOL t);
void rgss_set_mouse_mbutton(BOOL t);
void rgss_set_mouse_rbutton(BOOL t);

void ime_composition_pipe1(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void ime_composition_pipe2(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void ime_composition_pipe3(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

void on_ime_context(WPARAM wParam);

void add_new_char(TCHAR wch);
void add_new_string(TCHAR* wstr);
void add_new_string2(char* wstr);
void add_new_string3(TCHAR* wstr);

void remove_last_char();

void update_composition_text(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

RSDLL int is_key_down(BYTE virtualKey);
RSDLL int was_key_pressed(BYTE virtualKey);
RSDLL int is_any_key_down();
RSDLL long get_mouse_x();
RSDLL long get_mouse_y();
RSDLL BOOL get_mouse_lbutton();
RSDLL BOOL get_mouse_mbutton();
RSDLL BOOL get_mouse_rbutton();
RSDLL BOOL is_composing();
RSDLL void clear();
RSDLL void clear_text();
RSDLL const char* get_text();

typedef int(*RGSSEvalProto)(const char*);
typedef int(*RGSSSetStringUTF16Proto)(const char*, const wchar_t*);
typedef const wchar_t*(*RGSSGetStringUTF16Proto)(const char*);
typedef int(*RGSSSetStringUTF8Proto)(const char*, const char*);
typedef const char*(*RGSSGetStringUTF8Proto)(const char*);
typedef int(*RGSSGetIntProto)(const char*);
typedef BOOL(*RGSSGetBoolProto)(const char*);
typedef int(*RGSSSetStringProto)(const char*, const char*);

struct RGSSFunctions
{
	RGSSEvalProto           _pRGSSEval;
	RGSSSetStringUTF16Proto _pRGSSSetStringUTF16;
	RGSSGetStringUTF16Proto _pRGSSGetStringUTF16;
	RGSSSetStringUTF8Proto  _pRGSSSetStringUTF8;
	RGSSGetStringUTF8Proto  _pRGSSGetStringUTF8;
	RGSSGetIntProto         _pRGSSGetInt;
	RGSSGetBoolProto        _pRGSSGetBool;
	RGSSSetStringProto      _pRGSSSetString;

	RGSSFunctions() :
		_pRGSSEval(NULL),
		_pRGSSSetStringUTF16(NULL),
		_pRGSSGetStringUTF16(NULL),
		_pRGSSSetStringUTF8(NULL),
		_pRGSSGetStringUTF8(NULL),
		_pRGSSGetInt(NULL),
		_pRGSSGetBool(NULL),
		_pRGSSSetString(NULL)
	{

	}
};

#ifdef __cplusplus
}
#endif

#endif