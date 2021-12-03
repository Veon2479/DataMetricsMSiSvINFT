unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ExtDlgs,
  Vcl.Grids,
  Math,
  System.ioutils,
  types,
  ShellApi,
  ParseAnalys,
  CodeParser,
  Spen,
  Chepin,
  customTypes;


type
  TTMainForm = class(TForm)
    CodeInput: TMemo;
    LoadCodeFromFile: TOpenTextFileDialog;
    BOpenFile: TButton;
    BCount: TButton;
    ResultGrid: TStringGrid;
    procedure Created(Sender: TObject);
    procedure BOpenFileClick(Sender: TObject);
    procedure BCountClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TMainForm: TTMainForm;
  filename: string;

  fileIn, fileOut : TextFile;

  lexems          : TArray;



implementation

{$R *.dfm}

var i, j, cntT, cntC, cntM, cntP, nextCnt, maxCnt: integer; SpenRes: tSpens;

procedure TTMainForm.BOpenFileClick(Sender: TObject);
begin
    // CLICK
    LoadCodeFromFile.Execute();
    // get name clicked
    with LoadCodeFromFile.Files do
        filename:= LoadCodeFromFile.Files.Strings[count - 1];

    CodeInput.Lines.LoadFromFile(filename);
    //AssignFile(fileIn, filename, CP_UTF8);   // open file
    //writeln('LOG: opened file ', filename);

end;

procedure TTMainForm.BCountClick(Sender: TObject);
var i, j, tmp1, tmp2, maxLen: integer;

    procedure writeTable(const qset: QSet; const xcord: integer);
    var i, j: integer;
    begin
        nextCnt:= 2;
        with qset do
            for i := 0 to len - 1 do
                with table[i] do
                    for j := 0 to len - 1 do
                        if arr[j] <> '' then
                        begin
                            if (nextCnt >= ResultGrid.RowCount) then
                                ResultGrid.RowCount := nextCnt;
                            ResultGrid.Cells[xcord, nextCnt] := arr[j];
                            inc(nextCnt);
                        end;
        if maxCnt < nextCnt then
            maxCnt:= nextCnt;

    end;

begin

    // clear old
    with ResultGrid do
        for i := 2 to RowCount do
            for j := 1 to ColCount do
                Cells[j, i]:= '';


    // load file
    CodeInput.Lines.SaveToFile('cache.txt');

    AssignFile(fileIn, 'cache.txt', CP_UTF8);   // open file

    // anCode -- get all lexems
    //  lexems  -- dyn array of str with lexems
    //  nLexems -- amount of lexems
    reset(fileIn);
    anCode(fileIn, lexems, nLexems);
    closeFile(fileIn);

    if (nLexems < 1) then
        exit;
    // count chepin
    SpenRes := getSpenAnalys(lexems, nLexems);    //this array doesn't contain void fields
    countChepin(lexems, nLexems);
    crutch(SpenRes);


    with ResultGrid do
    begin
        // write vars
        maxCnt:= 0;
        // for eack ############################
        writeTable(vtypeT, 1);
        writeTable(vtypeP, 2);
        writeTable(vtypeM, 3);
        writeTable(vtypeC, 4);
        // end #########################################
        ResultGrid.RowCount := nextCnt + 3;

        // write cnt
        Cells[0, maxCnt] := 'Число';


        cntT := qcount(vtypeT);
        cntC := qcount(vtypeC);
        cntM := qcount(vtypeM);
        cntP := qcount(vtypeP);

        Cells[1, maxCnt] := IntToStr( cntT);
        Cells[2, maxCnt] := IntToStr( cntP);
        Cells[3, maxCnt] := IntToStr( cntM);
        Cells[4, maxCnt] := IntToStr( cntC);

        // write res
        Cells[1, maxCnt + 1] := FloatToStr( (cntT * 0.5 + cntM * 2 + cntC * 3 + cntP) );


        // count IO
        qmul(vtypeT, vtypeIO);
        qmul(vtypeP, vtypeIO);
        qmul(vtypeM, vtypeIO);
        qmul(vtypeC, vtypeIO);
        // write res
        writeTable(vtypeT, 5);
        writeTable(vtypeP, 6);
        writeTable(vtypeM, 7);
        writeTable(vtypeC, 8);

        cntT := qcount(vtypeT);
        cntC := qcount(vtypeC);
        cntM := qcount(vtypeM);
        cntP := qcount(vtypeP);

        Cells[5, maxCnt] := IntToStr( cntT);
        Cells[6, maxCnt] := IntToStr( cntP);
        Cells[7, maxCnt] := IntToStr( cntM);
        Cells[8, maxCnt] := IntToStr( cntC);

        // write res
        Cells[0, maxCnt + 1] := 'Результат';
        Cells[5, maxCnt + 1] := FloatToStr( (cntT * 0.5 + cntM * 2 + cntC * 3 + cntP) );

        // SPENS #########################################
        Cells[0, maxCnt + 2] := 'ID';
        Cells[1, maxCnt + 2] := 'спен';

        // for spen do
       // SpenRes := getSpenAnalys(lexems, nLexems);    //this array doesn't contain void fields

        maxCnt := maxCnt + 3;
        ResultGrid.RowCount := maxCnt + length(SpenRes) + 1;

        for i := 0 to length(SpenRes)-1 do
        begin
            Cells[0, maxCnt + i] := SpenRes[i].lexem;
            Cells[1, maxCnt + i] := IntToStr(SpenRes[i].spen);
        end;
        Cells[0, ResultGrid.RowCount - 1] := 'Результат';
        Cells[1, ResultGrid.RowCount - 1] :=  IntToStr(  getProgSpen(SpenRes));


    end;


    

end;

procedure TTMainForm.Created(Sender: TObject);
var i, j : integer;
begin
    // setup file input filtrer
    LoadCodeFromFile.Filter := 'Java proj files (*.java)|*.java|Txt files (*.txt)|*.txt|All files (*.*)|*.*';
    // setup headers
    with ResultGrid do
    begin
        Cells[0, 0] := 'RESULTS';
        Cells[1, 0] := 'Полная';
        Cells[5, 0] := 'IO';

        Cells[0, 1] := 'Группа';
        Cells[1, 1] := 'T';
        Cells[2, 1] := 'P';
        Cells[3, 1] := 'M';
        Cells[4, 1] := 'C';
        Cells[5, 1] := 'T';
        Cells[6, 1] := 'P';
        Cells[7, 1] := 'M';
        Cells[8, 1] := 'C';

        Cells[0, 2] := 'Переменные';
    end;
end;

end.
