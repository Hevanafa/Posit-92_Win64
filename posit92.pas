unit Posit92;

{$Mode TP}

interface

type
  TPosit92 = object
  public
    procedure init;
    {
    procedure afterInit;
    procedure cleanup;
    procedure update;
    procedure draw;
    }
  private
  end;


implementation

procedure TPosit92.init;
begin
  writeln('init from TPosit92!')
end;

end.
