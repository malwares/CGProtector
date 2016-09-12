{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{                  version 3.56 (241)                   }
{               build 241  (13 Oct 2008)                }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}

{.$DEFINE RSL_TRIAL}
{.$DEFINE RSL_CUSTOMIZE}
{$DEFINE RSL_AUTOLINKREFERENCES}
{.$DEFINE RSL_ENUMASINTEGER}
{.$DEFINE RSL_UNICODE}
{.$DEFINE RSL_STORAGE_PUBLICLINK}

{$IFDEF RSL_CUSTOMIZE}
  {.$DEFINE RSL_DEBUG}

  {$IFDEF  RSL_DEBUG}
    {$D+,L+,C+,YD}
  {$ELSE}
    {$Y-,C-,L-,D-}
  {$ENDIF}
{$ENDIF}


// Check Delphi and CBuilder versions

{$IFDEF VER100}
   {$DEFINE RSL_D3}
   {$DEFINE RSL_CB3LE}
   {$DEFINE RSL_D4LE}
   {$DEFINE RSL_CB4LE}
   {$DEFINE RSL_D5LE}
{$ENDIF}

{$IFDEF VER110}
   {$DEFINE RSL_CB3}
   {$DEFINE RSL_CB3LE}
   {$DEFINE RSL_D4LE}
   {$DEFINE RSL_CB4LE}
   {$DEFINE RSL_D5LE}
{$ENDIF}

{$IFDEF VER120}
   {$DEFINE RSL_D4}
   {$DEFINE RSL_D4LE}
   {$DEFINE RSL_CB4LE}
   {$DEFINE RSL_D5LE}
{$ENDIF}

{$IFDEF VER125}
   {$DEFINE RSL_CB4}
   {$DEFINE RSL_CB4LE}
   {$DEFINE RSL_D5LE}
{$ENDIF}

{$IFDEF VER130}
   {$DEFINE RSL_D5}
   {$DEFINE RSL_D5GE}
   {$DEFINE RSL_D5LE}
{$ENDIF}

{$IFDEF VER140}
   {$DEFINE RSL_D6}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}
{$ENDIF}

{$IFDEF VER150}
   {$DEFINE RSL_D7}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}
{$ENDIF}

{$IFDEF VER170}
   {$DEFINE RSL_D9}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}
{$ENDIF}

{$IFDEF VER180}
   {$DEFINE RSL_BDS4}
   {$DEFINE RSL_D9GE}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}
{$ENDIF}

{$IFDEF VER185}
   {$DEFINE RSL_D2007}
   {$DEFINE RSL_BDS4GE}
   {$DEFINE RSL_D9GE}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}
{$ENDIF}

{$IFDEF VER200}
   {$DEFINE RSL_BDS6}
   {$DEFINE RSL_BDS5GE}
   {$DEFINE RSL_BDS4GE}
   {$DEFINE RSL_D9GE}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}

  {$WARN WIDECHAR_REDUCED OFF}
  {$DEFINE RSL_UNICODE}
{$ENDIF}

{$IFDEF VER210}
   {$DEFINE RSL_BDS6}
   {$DEFINE RSL_BDS5GE}
   {$DEFINE RSL_BDS4GE}
   {$DEFINE RSL_D9GE}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}

  {$WARN WIDECHAR_REDUCED OFF}
  {$DEFINE RSL_UNICODE}
{$ENDIF}

{$IFDEF VER220}
   {$DEFINE RSL_BDS6}
   {$DEFINE RSL_BDS5GE}
   {$DEFINE RSL_BDS4GE}
   {$DEFINE RSL_D9GE}
   {$DEFINE RSL_D7GE}
   {$DEFINE RSL_D6GE}
   {$DEFINE RSL_D5GE}

  {$WARN WIDECHAR_REDUCED OFF}
  {$DEFINE RSL_UNICODE}
{$ENDIF}

{$IFDEF LINUX}
   {$DEFINE RSL_KYLIX}
{$ELSE}
   {$DEFINE RSL_WIN}
{$ENDIF}

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IFDEF RSL_KYLIX}
    {$IF RTLVersion>=14.5}
      {$DEFINE RSL_K3}
    {$ELSE}
      {$DEFINE RSL_K2LE}
    {$IFEND}
  {$ENDIF}
{$ENDIF}

{$IFDEF LINUX}
  {$IFDEF RSL_KYLIX}
    {$DEFINE RSL_REALKYLIX}
  {$ENDIF}
{$ENDIF}

{$IFNDEF RSL_CB3LE} 
  {$DEFINE RSL_INT64}   // int64 operations for Delphi4,CBuilder4 or late
{$ENDIF}


{$IFDEF RSL_D6GE}
  {$DEFINE RSL_NEWDLG}
  {.$DEFINE RSL_DLG_EXT}
{$ENDIF}


{$B-} { Complete Boolean Evaluation }
{$H+} { Use long string }
{$X+} { Extended syntax }

