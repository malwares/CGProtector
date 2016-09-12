//---------------------------------------------------------------------------

#include <basepch.h>
#pragma hdrstop

#pragma link "gdiplus.lib"
#pragma link "wininet.lib"

USEFORMNS("AdvDBComboBoxListEditor.pas", Advdbcomboboxlisteditor, ComboListEditor);
USEFORMNS("AdvStyles.pas", Advstyles, AdvStyleForm);
USEFORMNS("AdvExplorerTreeviewStyles.pas", Advexplorertreeviewstyles, AdvExplorerTreeviewStyleForm);
USEFORMNS("AdvExplorerTreeviewEditor.pas", Advexplorertreevieweditor, ExpTreeviewEditor);
USEFORMNS("GDIPPictureContainerEditor.pas", Gdippicturecontainereditor, GDIPPictureContainerEditor);
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
 