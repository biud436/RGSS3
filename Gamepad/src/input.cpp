#define _RSDLL

#include "input.h"

ControllerState controllers[MAX_CONTROLLERS];

RSDLL void RSCheckControllers(char* states)
{
	DWORD result;
	DWORD i;

	for (i = 0; i < MAX_CONTROLLERS; i++)
	{
		result = XInputGetState(i, &controllers[i].state);
		if (result == ERROR_SUCCESS) {
			controllers[i].connected = TRUE;
			states[i] = 't';
		}
		else {
			controllers[i].connected = FALSE;
			states[i] = 'f';
		}
	}
}

/************************************************************************/
/* DllMain                                                              */
/************************************************************************/

BOOL WINAPI DllMain(HINSTANCE hDllHandle,
	DWORD     nReason,
	LPVOID    Reserved)
{

	//  Perform global initialization.

	switch (nReason)
	{
	case DLL_PROCESS_ATTACH:
	{
	}
	break;

	case DLL_PROCESS_DETACH:
		break;
	}

	return TRUE;

}