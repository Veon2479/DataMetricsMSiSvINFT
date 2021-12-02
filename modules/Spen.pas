unit Spen;


interface

  uses
    customTypes;

function getSpenAnalys(const LEXEMS: tArray; const NLEXEMS: integer): tSpens;
function getProgSpen(const SPENS: tSpens): integer;

implementation

  procedure initArr(var ARR: tSpens);
    begin
      setLength(ARR, 1);
      ARR[0].spen := -1;
      ARR[0].lexem := '';
    end;

  function isFull(var ARR: tSpens): boolean;
    begin

    end;

  function getSpenAnalys(const LEXEMS: tArray; const NLEXEMS: integer): tSpens;
    begin
      initArr(RESULT);

    end;

  function getProgSpen(const SPENS: tSpens): integer;
    begin

    end;
end.
