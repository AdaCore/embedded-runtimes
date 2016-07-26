------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . E X P _ L L U                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2013, Free Software Foundation, Inc.         --
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

--  This function performs exponentiation of unsigned types (with binary
--  modulus values exceeding that of Unsigned_Types.Unsigned). The result
--  is always full width, the caller must do a masking operation if the
--  modulus is less than 2 ** (Long_Long_Unsigned'Size).

with System.Unsigned_Types;

package System.Exp_LLU is
   pragma Pure;

   function Exp_Long_Long_Unsigned
     (Left  : System.Unsigned_Types.Long_Long_Unsigned;
      Right : Natural)
      return  System.Unsigned_Types.Long_Long_Unsigned;

end System.Exp_LLU;
