unit customTypes;

interface


  type
    TArray = array of string;
    TChar = set of char;

    TErrors = (ENoError, EInvChar {= $0001}, ELongOp {= $0002}, ENotEnoughOps {= $0004},
               ENotEnoughBrackets, ELexemsBoundaryExeeded {= $0008});
    TCharType = (CUnexpected, CSpecial, CLetter, CSign, CDelimeter);

    tCountAr = array of record           //stores operands and operators and their count
                      lex: String;
                      num: integer;
                      isOperator: boolean;
                    end;

    tLexType = (lIf, lSwitch, lFor, lWhile, lRepeat, lConv, lNone, lCase);

    //////////Spen types////////////

    tSpenToken = record
      lexem: String;
      spen: integer;
    end;

    tSpens = array of tSpenToken;
    //////// QSET
    TStringArr = array of string;
    TStringDynArray = record
        len: integer;
        arr: TStringArr;
    end;
    PStringDynArray = ^TStringDynArray;
    TStringDynArrays = array of TStringDynArray;
    QSet = record
        table: TStringDynArrays;   // array of arrays
        len: integer; // len - full lenght of table, atOne - amount of chars
    end;

    ///


  const
        ERRORMSG: array [TErrors] of string = (
            'Everything is good! ',
            'ERROR! Invalid character detected',
            'ERROR! Too long operand detected',
            'ERROR! Not enough operands! Last readed:',
            'ERROR! Number of ''('' and '')'' symbols doesnt match',
            'ERROR! Parser exeeded number of readed lexems!');

        Letters : TChar = ['A'..'Z', 'a'..'z', '_', '0'..'9', '@', '^', '.', '#', '$'];
        Signs : TChar = ['~', ':', '=', '/', '\', '+', '-', '*', '%', '&', '|', '<', '>', '?', {';',} '''', ',', '"', '!'];
        Delimeters : TChar = ['{', '}', '[', ']', '(', ')', ';', ','];

        STR_VARIABLE_HEADER = ' int byte short long boolean char double float ';

      {  TYPES = ' int byte short long boolean char double float void ';
        PREFIXES = ' final private public protected static volatile transient native strictfp abstract synchronized new ';
        POSTFIXES = ' extends throws implements ';    // if classes ignored?
        STRUCTURES = ' class interface package enum ';                 //enum????
        CYCLES = ' do for while ';
        JUMPES = ' break return continue ';
        IGNORED = ' import class package'; //until the EoL
        ENTRIES = ' ( { = < : ? assert catch if else case switch default try catch finally throw';                  //;?????
                                                                 }



        MAJORENTRIES = ' ( { [ = ? : assert if switch try throw ';
        MINORENTRIES = ' else case default catch finally ';
        CYCLES = ' do for while ';
        JUMPES = ' break return continue ';
        SUPER_IGNORED = ' import class package enum '; //until the EoL
        IGNORED = 'new class interface package extends throws implements final private public protected static volatile transient native strictfp abstract synchronized new  int byte short long boolean char double float void String ';

        OP_SIGNS = ' ~ / \ +  - * % & | '' , " ; < > ';
        DSIGNS = ' <= >= == != ++ -- || && ';
        BLACKLIST = ' } ] ) ';


        STR_OP_ASS    = ' = += -= *= /= %= &= ^= |= <<= >>= >>>= ';
        STR_OP_UNAR   = ' ++ -- ~ ! ';
        STR_OP_LOGIC  = ' % & | && || ^ == != ';
        STR_OP_REL    = ' < > <= >= instanceof ';
        STR_OP_AR     = ' << >> >>> + - * / % ';
        //tLexType
        STR_lIf       = ' if ';
        STR_lSwitch   = ' switch ';
        STR_lFor      = ' for ';
        STR_lWhile    = ' while ';
        STR_lRepeat   = ' do ';
        STR_lConv     = ' ? ';
        STR_lCase     = ' case ';
        STR_lDeflt    = ' default ';

        STR_OPES_UNARY    = ' ++ -- ~ ! ';
        STR_OPES_BINARY   = ' += -= *= /= %= &= ^= |= <<= >>= >>>= % & | && || ^ == != < > <= >= instanceof '; // '=' excluded!!!!
        STR_OPES_QUESTION = ' + - ';
        STR_OPES_ALL      =  STR_OPES_QUESTION + STR_OPES_BINARY +  STR_OPES_UNARY;

        STR_COND_OPES = ' if switch for while ? ';
        STR_DEFINE_VAR = ' int float double String char boolean short long byte ';
        STRS_READ_VAR_AMOUNT = 9;
        STRS_READ_VAR  : array [1..STRS_READ_VAR_AMOUNT] of string = ('.readLine', '.nextLine',
            '.nextFloat', '.nextInt', '.nextDouble', '.nextByte', '.nextLong', '.nextShort', '.next');

        STR_OPERATORS = STR_OP_ASS + STR_OP_UNAR
                    + STR_OP_LOGIC + STR_OP_REL + STR_OP_AR
                    + STR_lIf + STR_lSwitch + STR_lFor + STR_lWhile
                    + STR_lRepeat + STR_lConv + STR_lCase;
        IGNORED_IO = ' Scanner System.in InPutStream OutPutStream FileOutputStream FileInputStream ';
        ALPHABET =  IGNORED_IO+BLACKLIST+DSIGNS+OP_SIGNS+IGNORED+SUPER_IGNORED+JUMPES+CYCLES+MINORENTRIES+MAJORENTRIES+STR_OPERATORS;

  var
    nLexems: integer;

  procedure push(const NUM: integer);
  function pop: integer;
  function peek(const NUM: integer): integer;     //number from the end of stack
  function getLen: integer;
  procedure resetStack;

  //function getHash(const member: shortString; const qset: QSet): integer; overload;
  //procedure qpush(const member: shortString; var qset: QSet);

  function qsearch(const member: shortString; const qset: QSet): integer;
  function qadd(const member: shortString; var qset: QSet): boolean;
  function qrm(const member: shortString; var qset: QSet): boolean;
  procedure qini(var qset: QSet; const len: integer);
  function qcount(const qset: QSet): integer;

  procedure qsum(var qsetA: QSet; const qsetB: QSet);
  procedure qmul(var qsetA: QSet; const qsetB: QSet);
  procedure qwrite(const qset: QSet);

  function isReserved(const ID: String): boolean;


implementation
  var
    Stack: array[1..200] of integer;
    SP: integer = 1;  //first empty

    procedure pushToArr(const member: shortString; var td: TStringDynArray);
    var i: integer;
    begin
        with td do
        begin
            i:= 0;
            while (i < len) and (arr[i] <> '') do
                inc(i);
            if (i < len) then // founded empty place
                arr[i] := member
            else
            begin
                // if array has place
                if Length(arr) <= len then
                    if Length(arr) = 0 then
                        SetLength(arr, 4)
                    else
                        SetLength(arr, len * 2);
                // add element
                arr[len] := member;
                inc(len);
            end;
        end;
    end;
    function delFromArr(const member: shortString; var td: TStringDynArray): boolean;
    var i: integer;
    begin
        i := 0;
        while (i < td.len) and (td.arr[i] <> member)  do
            inc(i);
        result:= (i < td.len);
        if result then
            td.arr[i] := '';
    end;
    function searchInArr(const member: shortString; var td: TStringDynArray): integer;
    begin
        Result := 0;
        with td do
        begin
            while (Result < len) and (arr[Result] <> member) do
                inc(Result);
            if (Result >= len) then
                Result:= -1;
        end;
    end;


    function getHash(const member: shortString; const qset: QSet): integer; overload;
    var c : ansichar;
    begin
        result := 0;
        for c in member do
            inc(result, ord(c));
        result:= Result mod qset.len;
    end;
    procedure qpush(const member: shortString; var qset: QSet);
    var i: integer;
    begin
        pushToArr(member, qset.table[getHash(member, qset)]);
    end;
    function qadd(const member: shortString; var qset: QSet): boolean;
    begin
        result:= (qsearch(member, qset)  = -1);
        if result then
            qpush(member, qset);
    end;
    procedure qini(var qset: QSet; const len: integer);
    var i : integer;
    begin
        qset.len := len;
        setLength(qset.table, len);
    end;
    function qsearch(const member: shortString; const qset: QSet): integer;
    begin
        result:= searchInArr(member, qset.table[getHash(member, qset)]);
    end;
    function qrm(const member: shortString; var qset: QSet): boolean;
    begin
        result:= delFromArr(member, qset.table[getHash(member, qset)]);
    end;
    function qcount(const qset: QSet): integer;
    var i, j: integer;
    begin
        result:= 0;
        with qset do
            for i := 0 to len - 1 do
                with table[i] do
                    for j := 0 to len - 1 do
                        if arr[j] <> '' then
                            inc(result);
    end;
    procedure qwrite(const qset: QSet);
    var i, j: integer;
    begin
        with qset do
                for i := 0 to len - 1 do
                    with table[i] do
                        for j := 0 to len - 1 do
                            if arr[j] <> '' then
                                write(arr[j], ', ');
        writeln;
    end;

  function isReserved(const ID: String): boolean;
    var
      code: integer;
    begin
      code := pos(' '+ID+' ', ALPHABET);
      if code <> 0 then RESULT:=true
        else RESULT:=false;

    end;

    procedure qsum(var qsetA: QSet; const qsetB: QSet);
    var i, j: integer;
    begin
        with qsetB do
            for i := 0 to len - 1 do
                with table[i] do
                    for j := 0 to len - 1 do
                        if arr[j] <> '' then
                            qadd(arr[j], qsetA);
    end;
    procedure qmul(var qsetA: QSet; const qsetB: QSet);
    var i, j: integer;
    begin
        with qsetA do
            for i := 0 to len - 1 do
                with table[i] do
                    for j := 0 to len - 1 do
                        if (qsearch(arr[j], qsetB) = -1) then
                            arr[j] := '';
    end;

  procedure push(const NUM: integer);
    begin
      Stack[SP]:=NUM;
      inc(SP);
    end;

  function pop: integer;
    begin
      RESULT:=Stack[SP-1];
      Stack[SP-1]:=0;
      dec(SP);
    end;

  function peek(const NUM: integer): integer;
    begin
      RESULT:=-1;
      if SP<>1 then
      RESULT:=Stack[SP-num];
    end;

  function getLen: integer;
    begin
      RESULT:=SP-1;
    end;

  procedure resetStack;
    var
      i: integer;
    begin
      SP:=1;
      for i:=1 to 200 do
      Stack[i]:=0;
    end;

end.
