with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;

procedure Spark with
   SPARK_Mode => On
is
   type Byte is mod 256;
   --  Also defines the max file size to be ~1MB
   type Instruction_Pointer_Type is mod 10**6;

   --   Impose some reasonable bounds for this example.
   subtype Data_Pointer_Type is Integer range 0 .. 10_000;
   Data_Stack : array (Data_Pointer_Type'Range) of Byte := (others => 0);

   --  10k loop depth (really the number of nested '[' characters).
   type Loop_Index_Type is mod 10_000;
   Loop_Stack : array (Loop_Index_Type'Range) of Instruction_Pointer_Type :=
     (others => 0);

   Loop_Stack_Index : Loop_Index_Type := 0;

   Instruction_Pointer : Instruction_Pointer_Type := 0;
   Data_Pointer        : Data_Pointer_Type        := 0;

   --   ~1MB file max
   Program : array (Instruction_Pointer_Type'Range) of Character :=
     (others => ASCII.NUL);

   Had_Error : Boolean := False;

   procedure Read_Program
     (File_Name : String; Len : out Instruction_Pointer_Type) with
      Global => (In_Out => (Ada.Text_IO.File_System, Program))
   is
      File  : Ada.Text_IO.File_Type;
      Input : Character;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
      pragma Assert (Ada.Text_IO.Is_Open (File));

      Len := 0;

      loop
         if Len = Instruction_Pointer_Type'Last then
            Put_Line ("Program is too big, sorry");
            exit;
         end if;

         Ada.Text_IO.Get (File, Input);
         Program (Len) := Input;

         Len := Len + 1;
         exit when Ada.Text_IO.End_Of_File (File);
      end loop;

      Ada.Text_IO.Close (File);
      pragma Assert (Ada.Text_IO.Is_Open (File) = False);
   end Read_Program;

   procedure Step with
      Global =>
      (In_Out =>
         (Data_Pointer, Data_Stack, Had_Error, Instruction_Pointer, Loop_Stack,
          Loop_Stack_Index, Ada.Text_IO.File_System),
       Input => Program)
   is
      Loop_Stack_Depth : Integer;
      Loop_End         : Instruction_Pointer_Type;
   begin
      case Program (Instruction_Pointer) is
         when '>' =>
            if Data_Pointer = Data_Pointer_Type'Last then
               Had_Error := True;
               return;
            end if;

            Data_Pointer := Data_Pointer + 1;
         when '<' =>
            if Data_Pointer = Data_Pointer_Type'First then
               Had_Error := True;
               return;
            end if;

            Data_Pointer := Data_Pointer - 1;
         when '+' =>
            Data_Stack (Data_Pointer) := Data_Stack (Data_Pointer) + 1;
         when '-' =>
            Data_Stack (Data_Pointer) := Data_Stack (Data_Pointer) - 1;
         when '.' =>
            Put (Item => Character'Val (Data_Stack (Data_Pointer)));
         when '[' =>
            Loop_Stack_Depth := 1;
            Loop_End         := Instruction_Pointer + 1;

            while Loop_Stack_Depth > 0 loop
               if Loop_Stack_Depth = Integer'Last then
                  Had_Error := True;
                  exit;
               end if;

               case Program (Loop_End) is
                  when '[' =>
                     Loop_Stack_Depth := Loop_Stack_Depth + 1;
                  when ']' =>
                     Loop_Stack_Depth := Loop_Stack_Depth - 1;
                  when others =>
                     null;
               end case;

               Loop_End := Loop_End + 1;
            end loop;

            if Data_Stack (Data_Pointer) = 0 then
               Instruction_Pointer := Loop_End;
            else
               Loop_Stack (Loop_Stack_Index) := Instruction_Pointer;
               Loop_Stack_Index              := Loop_Stack_Index + 1;
            end if;
         when ']' =>
            Loop_Stack_Index := Loop_Stack_Index - 1;

            if Data_Stack (Data_Pointer) /= 0 then
               Instruction_Pointer := Loop_Stack (Loop_Stack_Index) - 1;
            end if;
         when ',' =>
            --   TODO: support input.
            Had_Error := True;
         when others =>
            Had_Error := True;
      end case;
   end Step;

   --   Begin actual main :)
   Len : Instruction_Pointer_Type;
begin
   if Argument_Count /= 1 then
      Put_Line ("usage: ./spark <file>");
      return;
   end if;

   declare
      File_Name : constant String := Argument (1);
   begin
      Read_Program (File_Name, Len);
   end;

   while Instruction_Pointer < Len loop
      Step;

      if Had_Error then
         Put_Line ("Something spooky happened...");
         exit;
      end if;

      Instruction_Pointer := Instruction_Pointer + 1;
   end loop;
end Spark;
