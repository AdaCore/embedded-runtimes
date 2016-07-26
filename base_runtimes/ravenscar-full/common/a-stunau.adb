------------------------------------------------------------------------------
--                                                                          --
--                          GNAT RUN-TIME COMPONENTS                        --
--                                                                          --
--            A D A . S T R I N G S . U N B O U N D E D . A U X             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2009, Free Software Foundation, Inc.         --
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

package body Ada.Strings.Unbounded.Aux is

   ----------------
   -- Get_String --
   ----------------

   procedure Get_String
     (U : Unbounded_String;
      S : out Big_String_Access;
      L : out Natural)
   is
      X : aliased Big_String;
      for X'Address use U.Reference.all'Address;

   begin
      S := X'Unchecked_Access;
      L := U.Last;
   end Get_String;

   ----------------
   -- Set_String --
   ----------------

   procedure Set_String (UP : in out Unbounded_String; S : String_Access) is
   begin
      Finalize (UP);
      UP.Reference := S;
      UP.Last := UP.Reference'Length;
   end Set_String;

end Ada.Strings.Unbounded.Aux;
