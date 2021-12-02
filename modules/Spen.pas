unit Spen;


interface

  uses
    customTypes;

function getSpenAnalys(const LEXEMS: tArray; const NLEXEMS: integer): tSpens;
function getProgSpen(const SPENS: tSpens): integer;

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
                    if ((tmp>='0') and (tmp<='9')) then RESULT:=false
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
end.
