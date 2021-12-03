unit Chepin;

interface

 uses
    customTypes;

 var vtypeP, vtypeM, vtypeC, vtypeT, variables: QSet;

 procedure countChepin(var lexems: TArray; const nLexems: integer);


implementation

    function checkIsVarReaded(const lexem: string): boolean;
    var i : integer;
    begin
        result:= false; i:= 1;
        while not result and (i <= STRS_READ_VAR_AMOUNT) do
        begin
            result:= pos(STRS_READ_VAR[i], lexem ) <> 0;
            inc(i);
        end;
    end;

    procedure countChepin(var lexems: TArray; const nLexems: integer);
    var i: integer; lexem: string; inProgramm: boolean;
    begin
        i:= 0; inProgramm:= false;
        while i < nLexems do
        begin
            lexem := lexems[i];
            if lexem = '{' then // costili!! to enter main function!!!
                inProgramm := true;
            if inProgramm and (pos(' ' + lexem + ' ', STR_DEFINE_VAR) <> 0) then  // founded variable decl
            begin
                while lexems[i] <> ';' do
                begin
                    inc(i);
                    // were at var name
                    lexem := lexems[i];
                    qadd(lexem, vtypeT);
                    qadd(lexem, variables); // full qset with all variables used
                    // if lex = '='
                    repeat
                        inc(i);
                        if checkIsVarReaded(lexems[i]) then   // check if var readed from console
                        begin
                            qrm(lexem, vtypeT);
                            qadd(lexem, vtypeP);
                        end;
                    until (lexems[i] = ',') or (lexems[i] = ';');
                end;
            end
            else if inProgramm and (pos(' ' + lexem + ' ', STR_COND_OPES) <> 0) then
            begin

            end
            else if inProgramm and (qsearch(lexem, variables) <> -1) then
            begin
                qadd(lexem, vtypeM);
                // anal equation (until ;)
                inc(i);
                while lexems[i] <> ';' do
                begin
                    if (qsearch(lexems[i], variables) <> -1) then  // check on readable type
                        qadd(lexems[i], vtypeM);
                    inc(i);
                end;
            end;

            inc(i);
        end;
    end;



initialization
    qini(variables, 256);
    qini(vtypeP, 64);
    qini(vtypeM, 64);
    qini(vtypeC, 64);
    qini(vtypeT, 64);

end.
