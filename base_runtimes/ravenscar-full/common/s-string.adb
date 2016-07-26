------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . S T R I N G S                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1995-2013, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- You should have received a copy of the GNU General Public License along  --
-- with this library; see the file COPYING3. If not, see:                   --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

pragma Compiler_Unit_Warning;

package body System.Strings is

   ----------
   -- Free --
   ----------

   procedure Free (Arg : in out String_List_Access) is
      X : String_Access;

      procedure Free_Array is new Ada.Unchecked_Deallocation
        (Object => String_List, Name => String_List_Access);

   begin
      --  First free all the String_Access components if any

      if Arg /= null then
         for J in Arg'Range loop
            X := Arg (J);
            Free (X);
         end loop;
      end if;

      --  Now free the allocated array

      Free_Array (Arg);
   end Free;

end System.Strings;
