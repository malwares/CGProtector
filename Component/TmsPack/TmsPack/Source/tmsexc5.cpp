//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("tmsexc5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("AdvSyskeyboardHookReg.pas");
USERES("AdvSyskeyboardHookReg.dcr");
USEUNIT("AdvSyskeyboardHook.pas");
USEUNIT("AdvTouchkeyboardReg.pas");
USEUNIT("AdvTouchkeyboard.pas");
USEUNIT("calpreg.pas");
USERES("calpreg.dcr");
USEUNIT("calcomp.pas");
USEUNIT("calcreg.pas");
USERES("calcreg.dcr");
USEUNIT("calpanel.pas");
USEUNIT("exeinforeg.pas");
USERES("exeinforeg.dcr");
USEUNIT("ellipslabel.pas");
USEUNIT("ellipslblreg.pas");
USERES("ellipslblreg.dcr");
USEUNIT("exeinfo.pas");
USEUNIT("sysmreg.pas");
USERES("sysmreg.dcr");
USEUNIT("formsize.pas");
USEUNIT("frmshape.pas");
USEUNIT("frmsreg.pas");
USERES("frmsreg.dcr");
USEUNIT("fsreg.pas");
USERES("fsreg.dcr");
USEUNIT("hotspotimage.pas");
USEUNIT("hotspotimagereg.pas");
USERES("hotspotimagereg.dcr");
USEUNIT("layeredform.pas");
USEUNIT("lfreg.pas");
USERES("lfreg.dcr");
USEUNIT("linelibrary.pas");
USEUNIT("macrorecorder.pas");
USEUNIT("macrorecorderreg.pas");
USERES("macrorecorderreg.dcr");
USEUNIT("sysmon.pas");
USEPACKAGE("vcljpg50.bpi");
USEPACKAGE("vclsmp50.bpi");
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
