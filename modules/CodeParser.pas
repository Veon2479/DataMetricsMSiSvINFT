unit CodeParser;

interface
    uses
        System.SysUtils,
        Math,
        System.ioutils, types, StrUtils, // Vcl.Graphics,  Vcl.ExtCtrls,
        {Vcl.Dialogs, } classes,
        customTypes;

 //   type
       // TArray = array of string;

    //    TChar = set of char;

    //    TErrors = (ENoError, EInvChar {= $0001}, ELongOp {= $0002}, ENotEnoughOps {= $0004},
      //      ENotEnoughBrackets, ELexemsBoundaryExeeded {= $0008});
      //  TCharType = (CUnexpected, CSpecial, CLetter, CSign, CDelimeter);


    

    procedure parseLexem(var lexems: TArray; var lexem: string; var nLexems: integer);

    //procedure anLexems(const lexems: TArray; const nLexems: integer; var i: integer);

    procedure anCode(const input: textFile; out lexems: TArray; out nLexems: integer);

implementation

    // main
    procedure parseLexem(var lexems: TArray; var lexem: string; var nLexems: integer);
    begin
        if lexem <> '' then
        begin
            inc(nLexems);
            if nLexems = 0 then
                setLength(lexems, 1)
            else if length(lexems) <= nLexems then
                setLength(lexems, length(lexems) * 2);
            lexems[nLexems] :=  lexem;
            lexem:= '';
        end;
    end;

    procedure anCode(const input: textFile; out lexems: TArray; out nLexems: integer);
    var comment, finish, ignoreBracket: boolean;
        //c, c_last: char;  //
        chrType: TCharType;
        tmp_chr, last_tmp_chr: string; // complex char buffer
        lexem: string; // cur lexem

        ERROR: word;
        procedure handleError(const err: TErrors);
        var se: string;
        begin
            if ERROR = 0 then
            begin
                ERROR:= ord(err);
                lexem:= 'lexem <' + lexem + '>, last char met <' + tmp_chr + '>, previous sign char met <' + last_tmp_chr + '>';
                parseLexem(lexems, lexem, nLexems);
                se:= ERRORMSG[err];
                parseLexem(lexems, se, nLexems);
            end;
            //ShowMessage('WoopS! An error occured while parsing primary code! Code: ' + IntToStr(ord(err)));
            writeln('WoopS! An error occured while parsing primary code! '#13#10'Error msg: ', ERRORMSG[err], ' at lexem #', nLexems ,', '#13#10'caused by ', lexems[nLexems-1]);
            finish := true;
        end;
        function readNextChar(out next_char: string) : TCharType;// protected way to read next char
        var c: char;
        begin
            if Eof(input) then
            begin
                //handleError(ELexemsBoundaryExeeded);  // throw error
                result:= CUnexpected;
                finish := true;
                exit;
            end
            else
            begin
                read(input, c);
                next_char := c;

                if (c <= #$20) then     // detect char type
                    result := CSpecial
                else if c in Letters then
                    result:= CLetter
                else if c in Signs then
                    result:= CSign
                else if c in Delimeters then
                    result:= CDelimeter
                else
                    result:= CUnexpected;
                case c of  //isnt protected!! // this case is for detection of complex comment symbols (as /*,  //, \", \')
                    // <first char of complex symbol>: code that handles reading next symbol
                    '\': begin
                        read(input, c);
                        next_char:= next_char + c;
                    end;
                    '/': begin
                        read(input, c);    // Danger!! unprotected reading!
                        if (c = '*') or (c = '/') then  // next char belongs to complex symbol
                            next_char:= next_char + c
                        else  // next char is different
                        begin
                            parseLexem(lexems, next_char, nLexems);
                            next_char:= c;
                        end;
                    end;
                    '*': begin
                        read(input, c);   // Danger!! unprotected reading!
                        if (c = '/') then // next char belongs to complex symbol
                            next_char:= next_char + c
                        else    // next char is different
                        begin
                            parseLexem(lexems, next_char, nLexems);
                            next_char:= c;
                        end;
                    end;
                end;

            end;

        // temp unexpected char met
        if result = CUnexpected then
            handleError(EInvChar);
        end;

    begin
        nLexems:= -1; ERROR:= 0;

        comment:= false; finish:= false; // if were parsing comment; if ended b4 reaching Eof

        chrType:= readNextChar(tmp_chr);
        while (chrType <> CUnexpected) and not finish do//read file chr by chr
        begin
            while chrType = CLetter do  //parse word
            begin
                lexem := lexem + tmp_chr;

                chrType:= readNextChar(tmp_chr);// read next
            end;
            parseLexem(lexems, lexem, nLexems);

            while (chrType = CSign) and not comment and not finish do   //parse signs
            begin
                //check on "comment" start (grouped chars)
                if (tmp_chr = '/*') or (tmp_chr = '//') or (tmp_chr = '"') or (tmp_chr = '''') then
                    comment:= true ;
                lexem := lexem + tmp_chr;   // add symbol to lexem
                last_tmp_chr:= tmp_chr;     //save 1st comment symbol

                chrType:= readNextChar(tmp_chr); // read next
            end;

            while comment and not finish do                 //parse comment
            begin
                if chrType = CSpecial then
                    lexem := lexem + ' ' // replace control symbols with ' '
                else
                    lexem := lexem + tmp_chr;

                //if comment ended
                if ((last_tmp_chr = '''') and (tmp_chr = ''''))
                 or ((last_tmp_chr = '"') and (tmp_chr = '"'))
                 or ((last_tmp_chr = '/*') and (tmp_chr = '*/'))
                 or ((last_tmp_chr = '//') and (tmp_chr = #13)) then
                    comment := false;   // stop loop

                 chrType:= readNextChar(tmp_chr); // read next
            end;
            parseLexem(lexems, lexem, nLexems); // read next

            while (chrType = CDelimeter) and not finish do  //parse delimeters
            begin
                lexem := tmp_chr;
                parseLexem(lexems, lexem, nLexems);

                chrType:= readNextChar(tmp_chr); // read next
            end;

            while (chrType = CSpecial) and not finish do  //while "space" symbols wait for normal ones
                chrType:= readNextChar(tmp_chr); // read next
        end;

        //handle error (if proc returns negative num of lexems -- smth went wrong, 2 last lexems in array -- description of error
        if ERROR <> 0 then
            nLexems:= - nLexems;
    end;

initialization
end.
