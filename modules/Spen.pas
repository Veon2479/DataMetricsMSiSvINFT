unit Spen;


interface

  uses
    customTypes;

function getSpenAnalys(const LEXEMS: tArray; const NLEXEMS: integer): tSpens;
function getProgSpen(const SPENS: tSpens): integer;
function IOVarList(const VARS: tSpens; const LEXEMS: tArray; const NLEXEMS: integer): tSpens;

implementation
  var
    log: textfile;

  procedure initArr(var ARR: tSpens);
    begin
      setLength(ARR, 1);
      ARR[0].spen := -1;
      ARR[0].lexem := '';
    end;

  function isFull(var ARR: tSpens): boolean;
    var
      len: integer;
    begin
      len := length(ARR);
      if ARR[len-1].spen = -1 then RESULT:=false
        else RESULT:=true;
    end;

  procedure resize(var ARR: tSpens);
    var
      len, tmp: integer;
    begin
      len := length(ARR);
      tmp := len;
      len := len*2;
      setLength(ARR, len);
      for len:=tmp+1 to length(ARR)-1 do
        with ARR[len] do
          begin
            spen := -1;
            lexem := '';
          end;
    end;

  procedure cut(var ARR: tSpens);
    var
      tmp: integer;
    begin
      tmp := length(ARR)-1;
      while ARR[tmp].spen = -1 do
        dec(tmp);
      setLength(ARR, tmp+1);
    end;

  function findID(const ARR: tSpens; const BORDER: integer; const ID: String): integer;
    var
      i: integer;
    begin
      RESULT:=-1;
      for i:=0 to BORDER-1 do
        if ARR[i].lexem = ID then RESULT:=i;
    end;

  function isID(const LEXEMS: tArray; const POS: integer): boolean;
    var
      tmp: char;
    begin
      if isReserved(LEXEMS[POS]) then RESULT:=false
          else if LEXEMS[POS+1]='(' then RESULT:=false
              else
                  begin
                    tmp := LEXEMS[POS][1];
                    if ((tmp>='0') and (tmp<='9'))or(tmp='"')or(tmp='''')or(LEXEMS[POS]='true')or(LEXEMS[POS]='false')or(LEXEMS[POS]='null') then RESULT:=false
                        else RESULT:=true;
                  end;
    end;

  function getSpenAnalys(const LEXEMS: tArray; const NLEXEMS: integer): tSpens;
    var
      crnt, i, tmp: integer;
    begin
      assignFile(log, 'log.txt');
      rewrite(log);
      initArr(RESULT);
      crnt := 0;
      for i:=0 to NLEXEMS do
        begin
         // write(log, LEXEMS[i],' - ');
          if isID(LEXEMS, i) then
              begin
                writeln(log, LEXEMS[i], ' is ID');
                tmp := findID(RESULT, crnt, LEXEMS[i]);
                if tmp<>-1 then inc(RESULT[tmp].spen)
                  else
                    begin
                      if isFull(RESULT) then
                          resize(RESULT);
                      with RESULT[crnt] do
                        begin
                          lexem := LEXEMS[i];
                          spen := 0;
                        end;
                      inc(crnt);
                    end;
              end;
             // else writeln(log, 'something else');
        end;
      closeFile(log);
      cut(RESULT);
    end;

  function getProgSpen(const SPENS: tSpens): integer;
    var
      field: tSpenToken;
    begin
      RESULT:=0;
      for field in SPENS do
        inc(RESULT, field.spen);
    end;


  function IOVarList(const VARS: tSpens; const LEXEMS: tArray; const NLEXEMS: integer): tSpens;


        function isIOVar(const LEX: String): boolean;
          var
            posit, back, forw, count: integer;
            f: boolean;
          begin
            RESULT:=false;
            f:=true;
            posit:=0;
            while f do
              begin
                if ( pos('.next', LEXEMS[posit] )<>0)or (pos('.read', LEXEMS[posit])<>0 ) then
                    begin
                      back:=posit-1;
                      while not isID(LEXEMS, back) do
                        dec(back);
                      if LEXEMS[back]=LEX then
                          begin
                            RESULT:=true;
                            exit;
                          end;
                    end
                  else if ( pos('.print', LEXEMS[posit] )<>0)or (pos('.write', LEXEMS[posit])<>0 ) then
                      begin
                        forw:=posit+1;
                        count:=1;
                        while count<>0 do
                          begin
                            inc(forw);
                            if LEXEMS[forw]=LEX then
                                begin
                                  RESULT:=true;
                                  exit;
                                end;
                            if LEXEMS[forw]='(' then inc(count)
                              else if LEXEMS[forw]=')' then dec(count);
                          end;

                      end;
                if posit=NLEXEMS then f:=false;
                inc(posit);
              end;

          end;

    var
      i, count: integer;
    begin
      initArr(RESULT);
      count := 0;
      for i:=0 to length(VARS)-1 do
        begin
          if isIOVar(VARS[i].lexem) then
            begin
              if isFull(RESULT) then
                  resize(RESULT);
              RESULT[count] := VARS[i];
              inc(count);
            end;
        end;
      cut(RESULT);
    end;

end.
