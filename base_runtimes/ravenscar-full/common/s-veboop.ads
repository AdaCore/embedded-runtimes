------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--    S Y S T E M . V E C T O R S . B O O L E A N _ O P E R A T I O N S     --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2002-2009, Free Software Foundation, Inc.         --
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

--  This package contains functions for runtime operations on boolean vectors

package System.Vectors.Boolean_Operations is
   pragma Pure;

   --  Although in general the boolean operations on arrays of booleans are
   --  identical to operations on arrays of unsigned words of the same size,
   --  for the "not" operator this is not the case as False is typically
   --  represented by 0 and true by 1.

   function "not" (Item : Vectors.Vector) return Vectors.Vector;

   --  The three boolean operations "nand", "nor" and "nxor" are needed
   --  for cases where the compiler moves boolean array operations into
   --  the body of the loop that iterates over the array elements.

   --  Note the following equivalences:
   --    (not X) or  (not Y)  =  not (X and Y)  =  Nand (X, Y)
   --    (not X) and (not Y)  =  not (X or Y)   =  Nor  (X, Y)
   --    (not X) xor (not Y)  =  X xor Y
   --    X       xor (not Y)  =  not (X xor Y)  =  Nxor (X, Y)

   function Nand (Left, Right : Boolean) return Boolean;
   function Nor  (Left, Right : Boolean) return Boolean;
   function Nxor (Left, Right : Boolean) return Boolean;

   function Nand (Left, Right : Vectors.Vector) return Vectors.Vector;
   function Nor (Left, Right : Vectors.Vector) return Vectors.Vector;
   function Nxor (Left, Right : Vectors.Vector) return Vectors.Vector;

   pragma Inline_Always ("not");
   pragma Inline_Always (Nand);
   pragma Inline_Always (Nor);
   pragma Inline_Always (Nxor);
end System.Vectors.Boolean_Operations;
