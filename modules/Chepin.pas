unit Chepin;

interface

 uses
    customTypes;

 var vtypeP, vtypeM, vtypeC, vtypeT, vtypeIO: QSet;

 procedure countChepin(var lexems: TArray; const nLexems: integer);
 procedure crutch(const SPENS: tSpens);


implementation

    function checkIsVarReaded(const lexem: string): boolean;
    //var i : integer;
    begin
        result:= (pos('.next', lexem) <> 0) or (pos('.read', lexem) <> 0);//false; i:= 1;
    end;
    function checkIsVarOut(const lexem: string): boolean;
    begin
        result:= (pos('System.out.', lexem) <> 0);//false; i:= 1;
    end;

    procedure crutch(const SPENS: tSpens);
      var
        i: integer;
      begin
        for i:=0 to length(SPENS)-1 do
          begin
            if SPENS[i].spen=0 then
                begin
                  qadd(SPENS[i].lexem, vtypeT);
                end;
          end;

      end;

    procedure countChepin(var lexems: TArray; const nLexems: integer);
    var i, sqBktCnt, rndBktCtr, temp: integer; lexem: string; founded: boolean;
    begin
        i:= 0;
        // first stage: read all variables to T class
        while i < nLexems do
        begin
            if (pos(' ' + lexems[i] + ' ', STR_DEFINE_VAR) <> 0) then  // founded variable decl
            begin
                rndBktCtr := 0;
                while (lexems[i] <> ';') and (rndBktCtr >= 0) do
                begin
                    // check if array detected
                    sqBktCnt:= 0;
                    repeat
                        inc(i);
                        if lexems[i] = '[' then
                            inc(sqBktCnt)
                        else if lexems[i] = ']' then
                            dec(sqBktCnt);
                    until sqBktCnt = 0;
                    if lexems[i] = ']' then
                        inc(i);
                    // were at var name
                    lexem := lexems[i];
                    qadd(lexem, vtypeT);
                    // if lex = '='
                    repeat
                        inc(i);
                        if lexems[i] = '(' then
                            inc(rndBktCtr)
                        else if lexems[i] = ')' then
                            dec(rndBktCtr);
                    until (lexems[i] = ',') or (lexems[i] = ';') or (rndBktCtr < 0);
                end;
            end;
            inc(i);
        end;
        // second stage part 0. Get all writeble variables
        i:= 0;
        while i < nLexems do
        begin
            lexem:= lexems[i];

            if checkIsVarOut(lexems[i]) then
            begin
                rndBktCtr := 0;
                repeat // go right
                    inc(i);
                    if lexems[i] = '(' then
                        inc(rndBktCtr)
                    else if lexems[i] = ')' then
                        dec(rndBktCtr)
                    else if (qsearch(lexems[i], vtypeT) <> -1) then
                        qadd(lexems[i], vtypeIO);
                until (rndBktCtr <= 0);
            end;
            inc(i);
        end;
        // second stage: get all P (in) variables
        i:= 0;
        while i < nLexems do
        begin
            lexem:= lexems[i];

            if checkIsVarReaded(lexems[i]) then
            begin
                temp:= i;
                repeat // go left
                    dec(i);
                until lexems[i] = '=';
                dec(i);
                qrm(lexems[i], vtypeT);
                qadd(lexems[i], vtypeP);

                i:= temp;
            end;

            inc(i);
        end;

        qsum(vtypeIO, vtypeP);

        // 3rd stage: get all Mod vars ( find unary and binary operations;
        i:= 0;
        while i < nLexems do
        begin
            lexem:= lexems[i];
            if pos( ' ' + lexem + ' ', STR_OPES_ALL) <> 0 then  // founded binary oper
            begin
                rndBktCtr := 0;
                temp:= i;
                repeat // go left
                    dec(i);
                    if lexems[i] = '(' then
                        inc(rndBktCtr)
                    else if lexems[i] = ')' then
                        dec(rndBktCtr);
                    if (qsearch(lexems[i], vtypeT) <> -1) then
                    begin
                        qrm(lexems[i], vtypeT);
                        qadd(lexems[i], vtypeM);
                    end
                    else if (qsearch(lexems[i], vtypeP) <> -1) then
                    begin
                        qrm(lexems[i], vtypeP);
                        qadd(lexems[i], vtypeM);
                    end;
                until (rndBktCtr <= 0);
                i:= temp;
                repeat // go right
                    inc(i);
                    if lexems[i] = '(' then
                        inc(rndBktCtr)
                    else if lexems[i] = ')' then
                        dec(rndBktCtr);
                    if (qsearch(lexems[i], vtypeT) <> -1) then
                    begin
                        qrm(lexems[i], vtypeT);
                        qadd(lexems[i], vtypeM);
                    end
                    else if (qsearch(lexems[i], vtypeP) <> -1) then
                    begin
                        qrm(lexems[i], vtypeP);
                        qadd(lexems[i], vtypeM);
                    end;
                until (rndBktCtr <= 0);
            end;

            
            inc(i);
        end;
        // 4th stage: get all C vars
        i:= 0;
        while i < nLexems do
        begin
            lexem:= lexems[i];
            if (pos(' ' + lexem + ' ', STR_COND_OPES) <> 0) then
            begin
                // see data
                if lexem = 'for' then
                begin
                    rndBktCtr := 0;
                    repeat
                        inc(i);
                        if lexems[i] = '(' then
                            inc(rndBktCtr)
                        else if lexems[i] = ')' then
                            dec(rndBktCtr);
                        // if var is detected (COSTILI)
                        if (qsearch(lexems[i], vtypeT) <> -1) then
                        begin
                            qrm(lexems[i], vtypeT);
                            qadd(lexems[i], vtypec);
                            break;
                        end
                        else if (qsearch(lexems[i], vtypeM) <> -1) then
                        begin
                            qrm(lexems[i], vtypeM);
                            qadd(lexems[i], vtypec);
                            break;
                        end
                        else if (qsearch(lexems[i], vtypeP) <> -1) then
                        begin
                            qrm(lexems[i], vtypeP);
                            qadd(lexems[i], vtypec);
                            break;
                        end;
                    until (rndBktCtr <= 0);

                end
                else if (lexem = 'while') or (lexem = 'if') or (lexem = 'switch') then
                begin
                    rndBktCtr := 0;
                    repeat
                        inc(i);
                        if lexems[i] = '(' then
                            inc(rndBktCtr)
                        else if lexems[i] = ')' then
                            dec(rndBktCtr);
                        // if var is detected (COSTILI)
                        if (qsearch(lexems[i], vtypeT) <> -1) then
                        begin
                            qrm(lexems[i], vtypeT);
                            qadd(lexems[i], vtypec);
                        end
                        else if (qsearch(lexems[i], vtypeM) <> -1) then
                        begin
                            qrm(lexems[i], vtypeM);
                            qadd(lexems[i], vtypec);
                        end
                        else if (qsearch(lexems[i], vtypeP) <> -1) then
                        begin
                            qrm(lexems[i], vtypeP);
                            qadd(lexems[i], vtypec);
                        end;
                    until (rndBktCtr <= 0);

                end
                else if (lexem = '?') then
                begin
                    rndBktCtr := 0; founded:= false;  temp:= i;
                    repeat
                        dec(i);
                        if lexems[i] = ')' then
                            inc(rndBktCtr)
                        else if lexems[i] = '(' then
                            dec(rndBktCtr);
                        // if var is detected (COSTILI)
                        if (qsearch(lexems[i], vtypeT) <> -1) then
                        begin
                            qrm(lexems[i], vtypeT);
                            qadd(lexems[i], vtypec);
                            founded:= true;
                        end
                        else if (qsearch(lexems[i], vtypeM) <> -1) then
                        begin
                            qrm(lexems[i], vtypeM);
                            qadd(lexems[i], vtypec);
                            founded:= true;
                        end
                        else if (qsearch(lexems[i], vtypeP) <> -1) then
                        begin
                            qrm(lexems[i], vtypeP);
                            qadd(lexems[i], vtypec);
                            founded:= true;
                        end
                        else if (qsearch(lexems[i], vtypeC) <> -1) then
                            founded:= true;
                    until (rndBktCtr <= 0) and founded;
                    i:= temp;
                end;

            end;
            inc(i);
        end;
        inc(i);
//        i:= 0; inProgramm:= false;
//        while i < nLexems do
//        begin
//            lexem := lexems[i];
//            if lexem = '{' then // costili!! to enter main function!!!
//                inProgramm := true;
//            if inProgramm and (pos(' ' + lexem + ' ', STR_DEFINE_VAR) <> 0) then  // founded variable decl
//            begin
//                while lexems[i] <> ';' do
//                begin
//                    inc(i);
//                    // were at var name
//                    lexem := lexems[i];
//                    qadd(lexem, vtypeT);
//                    qadd(lexem, variables); // full qset with all variables used
//                    // if lex = '='
//                    repeat
//                        inc(i);
//                        if checkIsVarReaded(lexems[i]) then   // check if var readed from console
//                        begin
//                            qrm(lexem, vtypeT);
//                            qadd(lexem, vtypeP);
//                        end;
//                    until (lexems[i] = ',') or (lexems[i] = ';');
//                end;
//            end
//            else if inProgramm and (pos(' ' + lexem + ' ', STR_COND_OPES) <> 0) then
//            begin
//
//            end
//            else if inProgramm and (qsearch(lexem, variables) <> -1) then
//            begin
//                qadd(lexem, vtypeM);
//                // anal equation (until ;)
//                inc(i);
//                while lexems[i] <> ';' do
//                begin
//                    if (qsearch(lexems[i], variables) <> -1) then  // check on readable type
//                        qadd(lexems[i], vtypeM);
//                    inc(i);
//                end;
//            end;
//
//            inc(i);
//        end;
    end;



initialization
    qini(vtypeP, 64);
    qini(vtypeM, 64);
    qini(vtypeC, 64);
    qini(vtypeT, 64);
    qini(vtypeIO, 64);

end.
