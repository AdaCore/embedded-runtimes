------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . W I D _ L L U                        --
--                                                                          --
--                                 S p e c                                  --
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

--  This package contains the routine used for Width attribute for all
--  non-static unsigned integer (modular integer) subtypes. Note we only
--  have one routine, since this seems a fairly marginal function.

with System.Unsigned_Types;

package System.Wid_LLU is
   pragma Pure;

   function Width_Long_Long_Unsigned
     (Lo, Hi : System.Unsigned_Types.Long_Long_Unsigned)
      return   Natural;
   --  Compute Width attribute for non-static type derived from a modular
   --  integer type. The arguments Lo, Hi are the bounds of the type.

end System.Wid_LLU;
