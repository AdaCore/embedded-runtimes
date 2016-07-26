------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                     S Y S T E M .  M E M O R Y _ S E T                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--           Copyright (C) 2006-2014, Free Software Foundation, Inc.        --
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

pragma Restrictions (No_Elaboration_Code);

with Interfaces.C;

package System.Memory_Set is
   pragma Preelaborate;

   function Memset
     (M : Address; C : Interfaces.C.int; Size : Interfaces.C.size_t)
     return Address;
   pragma Export (C, Memset, "memset");
   --  This function stores C converted to a Character in each of the elements
   --  of the array of Characters beginning at M, with size Size. It returns a
   --  pointer to M.

end System.Memory_Set;
