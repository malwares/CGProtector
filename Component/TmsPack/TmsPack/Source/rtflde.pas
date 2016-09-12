{********************************************************************
TRTFLabel property editor
for Delphi 2.0,3.0,4.0,5.0, C++Builder 1.0,3.0,4.0
version 1.0

written by Bruno Fierens,
           TMS Software
           copyright © 1999
           Email : tms@theLinx.com
           Website : http://theLinx.com/tms
           Component page : http://users.skynet.be/delphi

The source code is given as is. The author is not responsible
for any possible damage done due to the use of this code.
The component can be freely used in any application. The complete
source code remains property of the author and may not be distributed,
published, given or sold in any form as such. No parts of the source
code can be included in any other component or application without
written authorization of the author.
********************************************************************}

unit Rtflde;

interface
{$I TMSDEFS.INC}
uses
  Classes, Forms, Dialogs, RTFLabel, FRTFBox, Messages, Windows, Controls,
{$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


type
 TRichTextProperty = class(TStringProperty)
                         public
                          function GetAttributes:TPropertyAttributes; override;
                          function GetValue:string; override;
                          procedure Edit; override;
                         end;


implementation


{ TRichTextProperty }

function TRichTextProperty.GetAttributes: TPropertyAttributes;
begin
 result:=[paDialog,paReadOnly];
end;

function TRichTextProperty.GetValue: string;
begin
 result:='(TRichText)';
end;

procedure TRichTextProperty.Edit;
var
 rtfbox:trtfbox;
 ms:tmemorystream;
 s:string;
 i:integer;
 ch:char;

begin
 rtfbox:=trtfbox.Create(application);
 try
  s:=(GetComponent(0) as TRTFLabel).RichText;
  ms:=tmemorystream.create;
  for i:=1 to length(s) do ms.write(s[i],1);
  ms.position:=0;
  rtfbox.RTFControl.lines.loadfromstream(ms);
  ms.free;

  if rtfbox.Showmodal=mrOk then
   begin
    ms:=tmemorystream.create;
    rtfbox.RTFControl.lines.savetostream(ms);
    ms.position:=0;
    s:='';
    if ms.size>0 then
       for i:=0 to ms.size-1 do
         begin
          ms.read(ch,1);
          s:=s+ch;
         end;
    ms.free;
    (GetComponent(0) as TRTFLabel).RichText:=s;
    (GetComponent(0) as TRTFLabel).Repaint;
    Modified;
   end;
 finally
  rtfbox.Free;
 end;
end;


end.
