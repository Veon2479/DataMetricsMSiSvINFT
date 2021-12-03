program cli_analyzer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Math,
  System.ioutils,
  types,
  ShellApi,
  Winapi.Windows,
  ParseAnalys in '..\modules\ParseAnalys.pas',
  CodeParser in '..\modules\CodeParser.pas',
  Spen in '..\modules\Spen.pas',
  Chepin in '..\modules\Chepin.pas',
  customTypes in '..\modules\customTypes.pas';

var
    Path, filename  : String;
    Files           : TStringDynArray;
    i               : integer;

    lexems          : TArray;

    fileIn, fileOut : TextFile;

    absDiff, relDiff, height: integer;

    SpenRes, IOSpenRes: tSpens;

begin

    filename := 'in.txt';
    AssignFile(fileIn, filename, CP_UTF8);   // open file
    writeln('LOG: opened file ', filename);

    // anCode -- get all lexems
    //  lexems  -- dyn array of str with lexems
    //  nLexems -- amount of lexems
    reset(fileIn);
    anCode(fileIn, lexems, nLexems);
    closeFile(fileIn);

    writeln('LOG: file was divided into tokens');
     AssignFile(fileOut, filename + '_out' + '.txt', CP_UTF8);   // open file
    rewrite(fileOut);
    for i := 0 to nLexems do
        writeln(fileOut, lexems[i]);
    closeFile(fileOut);

    writeln('LOG: output file for tokens was created');

    SpenRes := getSpenAnalys(lexems, nLexems);    //this array doesn't contain void fields
    writeln('ID''s spens: ');
    for i := 0 to length(SpenRes)-1 do
      writeln(SpenRes[i].lexem,' - ',SpenRes[i].spen);
    writeln('Program''s spen id: ', getProgSpen(SpenRes));
    writeln('Done!');

    writeln('LOG: counting spens completed');
    writeln('IO-variabels:');
    IOSPenRes:=IOVarList(SpenRes, Lexems, nLexems);
    if length(IOSpenRes)<>0 then

    for i := 0 to length(IOSpenRes)-1 do
      writeln(IOSpenRes[i].lexem,' - ',IOSpenRes[i].spen)
      else writeln('There''s no IO-vars');
    writeln('Done!');



    writeln('LOG: try to count chepin');
    countChepin(lexems, nLexems);
    crutch(SpenRes);
    writeln('CHEPIN TOT: var with type T: ', qcount(vtypeT));
    qwrite(vtypeT);
    writeln('CHEPIN TOT: var with type P: ', qcount(vtypeP));
    qwrite(vtypeP);
    writeln('CHEPIN TOT: var with type M: ', qcount(vtypeM));
    qwrite(vtypeM);
    writeln('CHEPIN TOT: var with type C: ', qcount(vtypeC));
    qwrite(vtypeC);


    writeln('########################### ');
    qmul(vtypeT, vtypeIO);
    qmul(vtypeP, vtypeIO);
    qmul(vtypeM, vtypeIO);
    qmul(vtypeC, vtypeIO);


    writeln('CHEPIN  IO: var with type T: ', qcount(vtypeT));
    qwrite(vtypeT);
    writeln('CHEPIN  IO: var with type P: ', qcount(vtypeP));
    qwrite(vtypeP);
    writeln('CHEPIN  IO: var with type M: ', qcount(vtypeM));
    qwrite(vtypeM);
    writeln('CHEPIN  IO: var with type C: ', qcount(vtypeC));
    qwrite(vtypeC);
    writeln('LOG: count chepin ended');

    // create output

    readln;

end.

