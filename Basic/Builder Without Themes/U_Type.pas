unit U_Type;

interface

type
  TExecute = record
    index : integer;
    Filename : string;
    Hidden : boolean;
    system : boolean;
  end;

  PBinder = ^TBinder;
  TBinder = record
    Delay : Integer;
    Exec : Byte;
    Path : Byte;
    Name : String;
    Parameter : String;
  end;

  TResource = record
    RType : integer;
    RName : String;
    RSplit : integer;
  end;

  TSection = record
    SName : string;
    Check1 : boolean;
    Check2 : boolean;
    Check3 : boolean;
    Check4 : boolean;
  end;

  TProxy = record
    Host : string;
    user : string;
    pass : string;
    Port : integer;
    ptype : integer;
  end;

  TMainSettings = record
    Execute : TExecute;
    Drop : TExecute;
    Resource : TResource;
    Section :TSection;
    Proxy : TProxy;
  end;

var
Settings :TMainSettings;
implementation

end.
