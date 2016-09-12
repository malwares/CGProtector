//---------------------------------------------------------------------------

#include <basepch.h>
#pragma hdrstop
#pragma link "gdiplus.lib"
USEFORMNS("moneycal.pas", Moneycal, CalForm);
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
