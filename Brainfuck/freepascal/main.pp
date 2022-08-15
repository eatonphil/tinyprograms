{$MODE objfpc}

program Brainfuck;

uses Sysutils;

function readFile(const fileName: string): string;
var c: char;
var fp: file of char;
begin
  result := '';

  assign(fp, fileName);
  reset(fp);

  while not eof(fp) do
  begin
    read(fp, c);
    result := result + c;
  end;

  close(fp);
end;

type generic vector<T> = class
  items: array of T;
  index: int64;
  procedure add(value: T);
  function pop(): T;
end;

procedure vector.add(value: T);
begin
  if (items = nil) or (length(items) = index) then
    setlength(items, (index + 1) * 2);

  items[index] := value;
  index += 1;
end;

function vector.pop(): T;
begin
  index -= 1;
  result := items[index];
end;

type IVector = specialize vector<integer>;

var prog: string;
var instrPointer: integer = 0;
var dataPointer: integer = 0;
var data: array[0..30000] of byte;
var instrStack: ivector;

// Used by '[' case
var bracketStack: integer;
var closingBracket: integer;

// Used by ']' case
var last: integer;

begin
  instrStack := ivector.create;
  fillchar(data, length(data), 0);

  prog := readFile(paramStr(1));

  while instrPointer < length(prog) do
  begin
    case (prog[instrPointer]) of
      '>': dataPointer += 1;
      '<': dataPointer -= 1;
      '+': data[dataPointer] += byte(1);
      '-': data[dataPointer] -= byte(1);
      '.': write(chr(data[dataPointer]));
      '[':
        // Find the equivalent (potentially nested) ending ']'
        begin
	  bracketStack := 1;
	  closingBracket := instrPointer + 1;
          while true do
	  begin
            if prog[closingBracket] = '[' then
	      bracketStack += 1;
	    if prog[closingBracket] = ']' then
	    begin
	      bracketStack -= 1;
	      if bracketStack = 0 then
	        break;
	    end;

            closingBracket += 1;
	  end;

          if data[dataPointer] = 0 then
	    instrPointer := closingBracket
          else instrStack.add(instrPointer);
	end;
      ']':
        begin
	  last := instrStack.pop();
          if data[dataPointer] <> 0 then
	    instrPointer := last - 1;
	end;
    end;

    instrPointer += 1;
  end;

  FreeAndNil(instrStack);
end.