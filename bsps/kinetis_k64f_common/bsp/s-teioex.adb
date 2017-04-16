with Memory_Protection;

package body System.Text_IO.Extended is
   ----------------
   -- Put_String --
   ----------------

   procedure Put_String (Str : String) is
   begin
      Memory_Protection.Enable_Background_Data_Region;
      for Char of Str loop
         loop
            exit when Is_Tx_Ready;
         end loop;

         Put (Char);
         if Char = ASCII.LF then
            Put (ASCII.CR);
         end if;
      end loop;

      Memory_Protection.Disable_Background_Data_Region;
   end Put_String;

end System.Text_IO.Extended;
