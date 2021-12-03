program Lab1_INTERFACE;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {TMainForm},
  ParseAnalys in '..\modules\ParseAnalys.pas',
  CodeParser in '..\modules\CodeParser.pas',
  Spen in '..\modules\Spen.pas',
  Chepin in '..\modules\Chepin.pas',
  customTypes in '..\modules\customTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTMainForm, TMainForm);
  Application.Run;
end.
