package body System.Text_IO.Extended is
   ----------------
   -- Put_String --
   ----------------

   procedure Put_String (Str : String) is
   begin
      for Char of Str loop
         loop
            exit when Is_Tx_Ready;
         end loop;

         Put (Char);
         if Char = ASCII.LF then
            Put (ASCII.CR);
         end if;
      end loop;
   end Put_String;

end System.Text_IO.Extended;
