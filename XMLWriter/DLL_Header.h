#ifndef DLL_HEADER__H__
#define DLL_HEADER__H__


#include <Windows.h>
#include <process.h>
#include <tchar.h>
#include <tinyxml.h>

#ifdef __cplusplus
extern "C"
{
#endif 

#define WIN32_LEAN_AND_MEAN

#ifdef _RSDLL
#define RSDLL __declspec(dllexport)
#else
#define RSDLL __declspec(dllimport)
#endif

	RSDLL DWORD RSCreateDoc(char* path);	// 테스트 파일 작성
	
	// Write
	RSDLL DWORD RSNewXmlDoc(void);
	RSDLL DWORD RSSaveXmlDoc(DWORD tiXmlDoc, char* path);
	RSDLL DWORD RSRemoveXmlDoc(DWORD tiXmlDoc);
	RSDLL DWORD RSCreateXmlElement(char* name);
	RSDLL void RSLinkEndChildFromDoc(DWORD xmlDoc, DWORD childElement);
	RSDLL void RSLinkEndChild(DWORD parentElement, DWORD childElement);
	RSDLL void RSSetAttribute(DWORD xmlElement, int dx, int dy, int index);

	// Read
	RSDLL int RSLoadXmlFile(DWORD tiXmlDoc, const char* filename);
	RSDLL DWORD RSGetRootElement(DWORD tiXmlDoc);

	typedef struct _TileIds
	{
		int dx;
		int dy;
		int index;
	} TileIds;

	RSDLL DWORD RSGetTileIds(DWORD xmlRootElement, TileIds data[]);

#ifdef __cplusplus
}
#endif 

#endif 