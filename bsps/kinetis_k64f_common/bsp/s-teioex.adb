with Memory_Protection;

package body System.Text_IO.Extended is
   ----------------
   -- Put_String --
   ----------------

   procedure Put_String (Str : String) is
      Was_In_Unprivilged_Mode_Before : Boolean;
   begin
      Was_In_Unprivilged_Mode_Before :=
         Memory_Protection.Enter_Privileged_Mode;
      --  ???
      if Was_In_Unprivilged_Mode_Before then
         Put ('@');
      end if;
      --  ???
      for Char of Str loop
         loop
            exit when Is_Tx_Ready;
         end loop;

         Put (Char);
         if Char = ASCII.LF then
            Put (ASCII.CR);
         end if;
      end loop;

      if Was_In_Unprivilged_Mode_Before then
         Memory_Protection.Exit_Privileged_Mode;
      end if;
   end Put_String;

end System.Text_IO.Extended;
