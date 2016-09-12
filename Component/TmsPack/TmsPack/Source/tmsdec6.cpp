//---------------------------------------------------------------------------

#include <basepch.h>
#pragma hdrstop
#pragma link "gdiplus.lib"
USEFORMNS("AdvExplorerTreeviewStyles.pas", Advexplorertreeviewstyles, AdvExplorerTreeviewStyleForm);
USEFORMNS("advdropdownstyles.pas", Advdropdownstyles, AdvDropDownStyleForm);
USEFORMNS("AdvDBComboBoxListEditor.pas", Advdbcomboboxlisteditor, ComboListEditor);
USEFORMNS("AdvStyles.pas", Advstyles, AdvStyleForm);
USEFORMNS("AdvSmoothStyles.pas", Advsmoothstyles, AdvSmoothStyleForm);
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
 