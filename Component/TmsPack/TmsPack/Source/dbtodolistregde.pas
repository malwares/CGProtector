{*************************************************************************}
{ TDBTodoList component                                                   }
{ for Delphi & C++Builder                                                 }
{ version 1.1                                                             }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2001 - 2004                                       }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{*************************************************************************}

unit DBTodoListRegDE;

interface

{$I TMSDEFS.INC}

uses
  DBTodoList, TodoListDE, DBTodoListDE, Classes,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.design.DesignIntf, Borland.Vcl.design.DesignEditors
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

  procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'SubjectField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'NotesField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'CreationDateField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'DueDateField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'CompletionDateField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'CompleteField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'CompletionField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'StatusField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'PriorityField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'KeyField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'ImageField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'ProjectField',TTodoListFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TTodoFields,'ResourceField',TTodoListFieldNameProperty);
  RegisterComponentEditor(TDBToDoList, TToDoListEditor);

end;

end.

