package body System.Text_IO.Extended is
   ----------------
   -- Put_String --
   ----------------

   procedure Put_String (Str : String) is
   begin
      for Char of Str loop
         Put (Char);
      end loop;
   end Put_String;

end System.Text_IO.Extended;
