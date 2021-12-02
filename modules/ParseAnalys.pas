unit ParseAnalys;



interface
  uses
    customTypes, Math;


  procedure countLex( var ABSDIFF, RELDIFF, HEIGHT: integer; var LEXEMS: TArray; const NLEX: integer);

implementation


  procedure countLex( var ABSDIFF, RELDIFF, HEIGHT: integer; var LEXEMS: TArray; const NLEX: integer);
    var
      cur, ending, curHeight: integer;
      curType: tLexType;


    function isRepeat(const LEX: integer): boolean;
      var
        counter, cur: integer;
      begin
        RESULT:=false;
        cur:=LEX+1;
        counter:=1;
        while counter<>0 do
          begin
            inc(cur);
            if LEXEMS[cur]='(' then inc(counter)
              else if LEXEMS[cur]=')' then dec(counter);
          end;
        if LEXEMS[cur+1]=';' then RESULT:=true;
      end;

    function detType(const LEX: integer): tLexType;
    var tmp : string;
    begin
        tmp := ' ' + lexems[LEX] + ' ';
        if      tmp = STR_lIf     then result:= lIf
        else if tmp = STR_lSwitch then result:= lSwitch
        else if tmp = STR_lFor    then result:= lFor
        else if tmp = STR_lWhile  then result:= lWhile
        else if tmp = STR_lRepeat then result:= lRepeat
        else if tmp = STR_lConv   then result:= lConv
        else if tmp = STR_lCase   then result:= lCase
        else if tmp = STR_lDeflt  then result:= lCase
        else                           result:= lNone;

        //определить какая лексема текущая - возможное использование пробегания вперёд
    end;

    function isOperator(const LEX: integer): boolean;
    begin
        //определить какая лексема текущая - возможное использование пробегания вперёд
        result := pos(' ' + lexems[LEX] + ' ', STR_OPERATORS) <> 0;
        if LEXEMS[LEX]='while' then
          if isRepeat(LEX) then result:=false;



    end;

    function findEnding(const LEX: integer; const LEXTYPE: tLexType): integer;
      var
        str: String;
        counter, count2, cur: integer;
      begin
        counter:=1;
        cur:=LEX+1;
        str:=LEXEMS[LEX];
        if (LEXTYPE=lIf) then
            begin
              while counter<>0 do
                begin
                  inc(cur);
                  if LEXEMS[cur]='(' then inc(counter)
                    else if LEXEMS[cur]=')' then dec(counter);
                end;

              inc(cur);
              if LEXEMS[cur]='{' then
                  begin
                    counter:=1;
                    while counter<>0 do
                      begin
                        inc(cur);
                        if LEXEMS[cur]='{' then inc(counter)
                          else if LEXEMS[cur]='}' then dec(counter);
                      end;
                  end
                else
                  while LEXEMS[cur]<>';' do
                    inc(cur);

              if LEXEMS[cur+1]='else' then
                  begin
                    inc(cur, 2);
                    if LEXEMS[cur]='{' then
                        begin
                          counter:=1;
                          while counter<>0 do
                            begin
                              inc(cur);
                              if LEXEMS[cur]='{' then inc(counter)
                                else if LEXEMS[cur]='}' then dec(counter);
                            end;
                        end
                      else
                        while LEXEMS[cur]<>';' do
                          inc(cur);

                  end;

            end
          else if (LEXTYPE=lCase) then
              begin
                while counter<>0 do
                  begin
                    inc(cur);
                    if LEXEMS[cur]='{' then inc(counter)
                      else if LEXEMS[cur]='}' then dec(counter);
                  end;
              end

        {    else if (str='do') then
                begin

                end  }

              else if (LEXTYPE=lRepeat) then
                  begin
                    while counter<>0 do
                      begin
                        inc(cur);
                        if LEXEMS[cur]='do' then inc(counter)
                          else if LEXEMS[cur]='while' then
                              begin
                                count2:=1;
                                inc(cur);
                                while count2<>0 do
                                  begin
                                    inc(cur);
                                    if LEXEMS[cur]='(' then inc(count2)
                                        else if LEXEMS[cur]=')' then dec(count2);
                                  end;
                                inc(cur);
                                if LEXEMS[cur]=';' then dec(counter);

                              end;

                      end;
                  end
                else if (LEXTYPE=lWhile) then
                    begin
                        while counter<>0 do
                          begin
                            inc(cur);
                            if LEXEMS[cur]='(' then inc(counter)
                              else if LEXEMS[cur]=')' then dec(counter);
                          end;

                        inc(cur);
                        if LEXEMS[cur]='{' then
                            begin
                              counter:=1;
                              while counter<>0 do
                                begin
                                  inc(cur);
                                  if LEXEMS[cur]='{' then inc(counter)
                                    else if LEXEMS[cur]='}' then dec(counter);
                                end;
                            end
                          else
                            while LEXEMS[cur]<>';' do
                              inc(cur);
                    end
                  else if (LEXTYPE=lFor) then
                      begin
                        while counter<>0 do
                          begin
                            inc(cur);
                            if LEXEMS[cur]='(' then inc(counter)
                              else if LEXEMS[cur]=')' then dec(counter);
                          end;

                        inc(cur);
                        if LEXEMS[cur]='{' then
                            begin
                              counter:=1;
                              while counter<>0 do
                                begin
                                  inc(cur);
                                  if LEXEMS[cur]='{' then inc(counter)
                                    else if LEXEMS[cur]='}' then dec(counter);
                                end;
                            end
                          else
                            while LEXEMS[cur]<>';' do
                              inc(cur);
                      end
                    else if (LEXTYPE=lConv) then
                        begin
                          while LEXEMS[cur]<>';' do
                            inc(cur);
                        end
                      else RESULT:=LEX;

        RESULT:=cur;
      end;

    begin
      resetStack;
      cur:=0;	// cur lex num
      HEIGHT:=0;	// cur max height
      curHeight:=0;	// cur block height
      ending:=NLEX;	// lexems bound
      while cur<=NLEX do
        begin


            if isOperator(cur) then
            begin
               // writeln('operators:  ',LEXEMS[cur]);
             inc(RELDIFF);	// count sum of operators
             curType:=detType(cur);
             if curType=lSwitch then
                inc(ABSDIFF);
             if curType=lCase then dec(RELDIFF);
             if (curType<>lNone)and(curType<>lSwitch) then
              begin
                if curType<>lCase then inc(ABSDIFF);
                
                if LEXEMS[cur]<>'default' then
                  begin
                    push(ending);
                    ending:=findEnding(cur, curType);     //конец блока, в котором могут быть вложенные условия
                                                      //для контроля вложенности
                  end;


                  //TODO:увеличение текущей высоты с учётом свитча и прочего
                curHeight:=getLen;
				        if curHeight>HEIGHT then HEIGHT:=curHeight;// check if max height reached
                  //DONE

              end;

            end;
                    //мне начинает казаться, что кроме этих двух TODO добавлять нечего
            inc(cur);
            if cur = ending then
            begin

              ending:=pop;
              while (getLen>0)and(peek(1)<=cur) do
                ending:=pop;

              {ending:=pop;
              if cur=ending then
              while (getLen>0)and(peek(1)=ending) do
                 ending:=pop;  }

                //TODO:уменьшение текущей высоты с учётом свитча и прочего
              curHeight:=getLen;
                //DONE

            end;
        end;

      //dec(HEIGHT);

      if RELDIFF<>0 then
      RELDIFF:=ABSDIFF*100 div RELDIFF;


    end;

end.
