#include <Windows.h>
#include <TlHelp32.h>
#include <tchar.h>
#include <cstdio>

enum {
	INJECTION_MODE,
	EJECTION_MODE
};

#define DEF_PROCESS_NAME (_T("Game.exe"))
#define DEF_DLL_NAME (_T("RSFont.dll"))

BOOL InjectDll2(LPCTSTR szDllPath)
{
	HANDLE hProcess = NULL;
	HANDLE hThread = NULL;
	HMODULE hMod = NULL;
	LPVOID pRemoteBuf = NULL;
	DWORD dwBufSize = (DWORD)(_tcslen(szDllPath) + 1) * sizeof(TCHAR);
	LPTHREAD_START_ROUTINE pThreadProc;

	STARTUPINFO si = { sizeof(STARTUPINFO), };
	PROCESS_INFORMATION pi;

	if (!CreateProcess(DEF_PROCESS_NAME,
		NULL,
		NULL,
		NULL,
		TRUE,
		0,
		NULL,
		NULL,
		&si,
		&pi))
	{
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
		_tprintf_s(_T("CreateProcess(%d) failed!!! [%d]\n"), pi.dwProcessId, GetLastError());
		return FALSE;
	}

	Sleep(200);

	hProcess = pi.hProcess;

	pRemoteBuf = VirtualAllocEx(hProcess, NULL, dwBufSize, MEM_COMMIT, PAGE_READWRITE);

	if (pRemoteBuf == NULL)
		return FALSE;

	WriteProcessMemory(hProcess, pRemoteBuf, (LPVOID)szDllPath, dwBufSize, NULL);

	hMod = GetModuleHandleA(_T("Kernel32.dll"));
	pThreadProc = (LPTHREAD_START_ROUTINE)GetProcAddress(hMod, "LoadLibraryA");

	hThread = CreateRemoteThread(hProcess, NULL, 0, pThreadProc, pRemoteBuf, 0, NULL);

	WaitForSingleObject(hThread, INFINITE);

	VirtualFreeEx(hProcess, pRemoteBuf, 0, MEM_RELEASE);

	CloseHandle(hProcess);
	CloseHandle(hThread);
	CloseHandle(pi.hThread);	

	return TRUE;
}

int _tmain(int argc, TCHAR *argv[])
{
	if (InjectDll2(DEF_DLL_NAME)) {
		_tprintf_s("DLL 인젝션에 성공하였습니다.");
	} else {
		_tprintf_s("DLL 인젝션에 실패하였습니다.");
	}
	
	return 0;
}