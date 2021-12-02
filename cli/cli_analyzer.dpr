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

    SpenRes: tSpens;

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

    // create output
    AssignFile(fileOut, filename + '_out' + '.txt', CP_UTF8);   // open file
    rewrite(fileOut);
    for i := 0 to nLexems do
        writeln(fileOut, lexems[i]);
    closeFile(fileOut);

    writeln('LOG: output file for tokens was created');

   { SpenRes := getSpenAnalys(lexems, nLexems);    //this array doesn't contain void fields
    writeln('ID''s spens: ');
    for i := 0 to length(SpenRes)-1 do
      writeln(SpenRes[i].lexem,' - ',SpenRes[i].spen);
    writeln('Program''s spen id: ', getProgSpen(SpenRes));
    writeln('Done!');     }



    readln;

end.

