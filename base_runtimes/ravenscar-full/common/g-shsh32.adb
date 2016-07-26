------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--           G N A T . S E C U R E _ H A S H E S . S H A 2 _ 3 2            --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--           Copyright (C) 2009, Free Software Foundation, Inc.             --
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

package body GNAT.Secure_Hashes.SHA2_32 is

   use Interfaces;

   ------------
   -- Sigma0 --
   ------------

   function Sigma0 (X : Word) return Word is
   begin
      return Rotate_Right (X, 2)
         xor Rotate_Right (X, 13)
         xor Rotate_Right (X, 22);
   end Sigma0;

   ------------
   -- Sigma1 --
   ------------

   function Sigma1 (X : Word) return Word is
   begin
      return Rotate_Right (X, 6)
         xor Rotate_Right (X, 11)
         xor Rotate_Right (X, 25);
   end Sigma1;

   --------
   -- S0 --
   --------

   function S0 (X : Word) return Word is
   begin
      return Rotate_Right (X, 7)
         xor Rotate_Right (X, 18)
         xor Shift_Right  (X, 3);
   end S0;

   --------
   -- S1 --
   --------

   function S1 (X : Word) return Word is
   begin
      return Rotate_Right (X, 17)
         xor Rotate_Right (X, 19)
         xor Shift_Right  (X, 10);
   end S1;

end GNAT.Secure_Hashes.SHA2_32;
