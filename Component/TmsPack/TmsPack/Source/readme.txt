
!!!! TMS COMPONENT PACK v5.7 BREAKING CHANGE NOTE !!!!
------------------------------------------------------

Change applied in Jul 3, 2010 update of TMS Component Pack Pro v5.7

1) Classes TMouseActions, TNavigation, TSearchFooter were moved from ADVGRID.PAS to ADVOBJ.PAS
  
   Add AdvObj to Uses clause if this causes compilation problems on existing projects

2) Types TSortStyle, TEditorType, TVAlignment, TCellGradientDirection were moved from ADVGRID.PAS to ADVOBJ.PAS

  
   Add AdvObj to Uses clause if this causes compilation problems on existing projects



!!!! TMS COMPONENT PACK v4.8 BREAKING CHANGE NOTE !!!!
------------------------------------------------------

Change applied in Oct 12, 2008 update of TMS Component Pack Pro v4.8

1) TAdvGridExcelIO is no longer supported under Delphi 5 / C++Builder 5 
   Users still needing this functionality for Delphi 5 / C++Builder 5, restore XlsAdapter source folder from backup
   and compile & install TMSXLSD5.DPK / TMSXLSC5.BPK

2) All TAdvGridExcelIO related files have been renamed to same filenames with 'tms' prefix.
   Change in the Uses list / Include files filenames to same filename with 'tms' prefix, ie:
   AdvGridExcel to tmsAdvGridExcel etc...



!!!! BREAKING CHANGE NOTE !!!!
------------------------------
Change applied in Feb 10, 2007 update of TMS Component Pack Pro v4.2

The TTaskDialog component was renamed to TAdvTaskDialog.
We were forced to make this breaking change. Replace TTaskDialog
component in your applications by TAdvTaskDialog.


Note about GDI+
---------------
The TMS Component Pack requires GDI+ to be installed on the development system.
The GDI+ API is used for complex gradient drawing antialiasing, PNG image support
with alpha transparency.

GDI+ might not be installed by default on your system. You can obtain a separate
GDI+ distribution from

http://www.microsoft.com/downloads/details.aspx?FamilyID=6A63AB9C-DF12-4D41-933C-BE590FEAA05A&displaylang=en

GDI+ is currently only required by following components: 

Always used in : TAdvToolBar, TAdOfficeHint, TAdvGlowButton, AdvCircularProgress, AdvSelectors 
Optionally used in : TAdvStringGrid,TAdvColumnGrid,TDBAdvGrid

Only when these components are used in your application, it might be necessary
to redistribute the GDI+ DLL with your application.

Note that GDI+ use can be disabled for TAdvStringGrid, TAdvColumnGrid,TDBAdvGrid.
To do this, open TMSDEFS.INC and comment the line {$DEFINE TMSGDIPLUS}


Note about using GDI+ with C++Builder
-------------------------------------
When using components that use GDI+, make sure that your app's main CPP file
includes the line:

#pragma link "gdiplus.lib"


Note about ADO support
----------------------
To use the TDBAdvGrid v2.0 component for ADO databases with dataset
sorts triggered from the grid, remove the line

{$DEFINE TMSNOADO}

from the file TMSDEFS.INC


Note about XP theme support for C++Builder 6
--------------------------------------------
An issue in the uxtheme.h file that is included with C++Builder 6
will cause problems when using TMS Components that include XP theme
support. The TMS Component Pack distribution contains a fixed uxtheme.h
file to solve this. Please copy this to ther {$BCB}\Include folder.


Note about TDBAdvStringGrid v1.7 / TDBAdvGrid v2.0
--------------------------------------------------

TDBAdvGrid v2.0 replaces TDBAdvStringGrid. By default TDBAdvStringGrid is no longer installed
as for new projects TDBAdvGrid v2.0 is the recommended component. 

TDBAdvStringGrid v1.7 is still included in the TMS Component Pack Pro distribution for
backwards compatibility. TDBAdvStringGrid will remain included in the TMS Component Pack Pro.
To avoid confusion for new users, it is only no longer installed on the component palette
by default.

You can install TDBAdvStringGrid in following way:

Delphi 5,6,7
------------
1) Open TMSDxx.DPK 

   Add dbgreg.pas to the package file from the Package file editor
   Save, compile & install the package file

2) Open TMSDEDxx.DPK
   
   Add dbgregde.pas to the package file from the Package file editor
   Save, compile & install the package file


C++Builder 5,6
--------------
1) Open TMSCxx.BPK 

   Add dbgreg.pas to the package file from the Package file editor
   Save, compile & install the package file

2) Open TMSDECxx.BPK
   
   Add dbgregde.pas to the package file from the Package file editor
   Save, compile & install the package file


Delphi 2005 VCL 
---------------

1) Open TMSD2005.bdsproj

   Add dbgreg.pas to the project file from the Project Manager
   Save, compile & install the project

2) Open TMSDED2005.bdsproj
   
   Add dbgregde.pas to the project file from the Project Manager
   Save, compile & install the project

Delphi 2005 VCL.NET
-------------------

1) Open TMSD2005NET.bdsproj

   Add dbgreg.pas to the project file from the Project Manager
   Save, compile & install the project

2) Open TMSDED2005NET.bdsproj
   
   Add dbgregde.pas to the project file from the Project Manager
   Save, compile & install the project


Delphi 2006 VCL 
---------------

1) Open TMSD2006.bdsproj

   Add dbgreg.pas to the project file from the Project Manager
   Save, compile & install the project

2) Open TMSDED2006.bdsproj
   
   Add dbgregde.pas to the project file from the Project Manager
   Save, compile & install the project


Delphi 2007 VCL 
---------------

1) Open TMSD2007.dproj

   Add dbgreg.pas to the project file from the Project Manager
   Save, compile & install the project

2) Open TMSDED2007.dproj
   
   Add dbgregde.pas to the project file from the Project Manager
   Save, compile & install the project


Delphi 2009 VCL 
---------------

TDBAdvStringGrid is not supported for Delphi 2009/C++Builder 2009. Please use TDBAdvGrid instead.
