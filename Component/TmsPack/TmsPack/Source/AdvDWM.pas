{***********************************************************************}
{ DWM API import                                                        }
{ for Delphi & C++ Builder                                              }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 2009 - 2010                                    }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The source       }
{ code remains property of the writer and may not be distributed        }
{ freely as such.                                                       }
{***********************************************************************}
unit AdvDWM;

{$HPPEMIT ''}
{$HPPEMIT '#include "dwmapi.h"'}
{$HPPEMIT ''}

{$I TMSDEFS.INC}
{$T-}

interface

uses
  Windows;


type
  _DWMMARGINS = record
    cxLeftWidth: Integer;
    cxRightWidth: Integer;
    cyTopHeight: Integer;
    cyBottomHeight: Integer;
  end {_DWMMARGINS};

  DWMMARGINS = _DWMMARGINS;
  PDWMMARGINS = ^_DWMMARGINS;
  TDWMMargins = DWMMARGINS;



{$EXTERNALSYM DwmDefWindowProc}
function DwmDefWindowProc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var plResult: LRESULT): BOOL;

{$EXTERNALSYM DwmExtendFrameIntoClientArea}
function DwmExtendFrameIntoClientArea(hWnd: HWND; const pMarInset: TDWMMargins): HResult;

{$EXTERNALSYM DwmIsCompositionEnabled}
function DwmIsCompositionEnabled(out pfEnabled: BOOL): HResult;

{$EXTERNALSYM DwmCompositionEnabled}
function DwmCompositionEnabled: Boolean;

implementation

uses
  SysUtils;

const
  ModName = 'DWMAPI.DLL';

var
  hDWMAPI: HMODULE;

var
  _DwmDefWindowProc: function(hWnd: HWND; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; var plResult: LRESULT): BOOL; stdcall;

  _DwmExtendFrameIntoClientArea: function(hWnd: HWND;
    const pMarInset: TDWMMargins): HResult; stdcall;

  _DwmIsCompositionEnabled: function(out pfEnabled: BOOL): HResult; stdcall;

//------------------------------------------------------------------------------

procedure InitDwmApi; //inline;
begin
  if hDWMAPI = 0 then
    hDWMAPI := LoadLibrary(ModName);
end;

//------------------------------------------------------------------------------

function DwmDefWindowProc(hWnd: HWND; msg: UINT; wParam: WPARAM;
  lParam: LPARAM; var plResult: LRESULT): BOOL;
begin
  if Assigned(_DwmDefWindowProc) then
    Result := _DwmDefWindowProc(hWnd, msg, wParam, lParam, plResult)
  else
  begin
    InitDwmApi;
    Result := False;
    if hDWMAPI > 0 then
    begin
      _DwmDefWindowProc := GetProcAddress(hDWMAPI, 'DwmDefWindowProc');
      if Assigned(_DwmDefWindowProc) then
        Result := _DwmDefWindowProc(hWnd, msg, wParam, lParam, plResult);
    end;
  end;
end;

//------------------------------------------------------------------------------

function DwmExtendFrameIntoClientArea(hWnd: HWND; const pMarInset: TDWMMargins): HResult;
begin
  if Assigned(_DwmExtendFrameIntoClientArea) then
    Result := _DwmExtendFrameIntoClientArea(hWnd, pMarInset)
  else
  begin
    InitDwmApi;
    Result := E_NOTIMPL;
    if hDWMAPI > 0 then
    begin
      _DwmExtendFrameIntoClientArea := GetProcAddress(hDWMAPI, 'DwmExtendFrameIntoClientArea');
      if Assigned(_DwmExtendFrameIntoClientArea) then
        Result := _DwmExtendFrameIntoClientArea(hWnd, pMarInset);
    end;
  end;
end;

//------------------------------------------------------------------------------

function DwmCompositionEnabled: Boolean;
var
  LEnabled: BOOL;
begin
  Result := (Win32MajorVersion >= 6) and (DwmIsCompositionEnabled(LEnabled) = S_OK) and LEnabled;
end;

//------------------------------------------------------------------------------

function DwmIsCompositionEnabled(out pfEnabled: BOOL): HResult;
begin
  if Assigned(_DwmIsCompositionEnabled) then
    Result := _DwmIsCompositionEnabled(pfEnabled)
  else
  begin
    InitDwmApi;
    Result := E_NOTIMPL;
    if hDWMAPI > 0 then
    begin
      _DwmIsCompositionEnabled := GetProcAddress(hDWMAPI, 'DwmIsCompositionEnabled');
      if Assigned(_DwmIsCompositionEnabled) then
        Result := _DwmIsCompositionEnabled(pfEnabled);
    end;
  end;
end;

//------------------------------------------------------------------------------

initialization

finalization
  if hDWMAPI > 0 then
    FreeLibrary(hDWMAPI);
end.
