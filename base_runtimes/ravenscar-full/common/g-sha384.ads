------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--                          G N A T . S H A 3 8 4                           --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--        Copyright (C) 2009-2011, Free Software Foundation, Inc.           --
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

--  This package implements the SHA-384 secure hash function as described in
--  FIPS PUB 180-3. The complete text of FIPS PUB 180-3 can be found at:
--    http://csrc.nist.gov/publications/fips/fips180-3/fips180-3_final.pdf

--  See the declaration of GNAT.Secure_Hashes.H in g-sechas.ads for complete
--  documentation.

with GNAT.Secure_Hashes.SHA2_Common;
with GNAT.Secure_Hashes.SHA2_64;
with System;

package GNAT.SHA384 is new GNAT.Secure_Hashes.H
  (Block_Words    => GNAT.Secure_Hashes.SHA2_Common.Block_Words,
   State_Words    => 8,
   Hash_Words     => 6,
   Hash_Bit_Order => System.High_Order_First,
   Hash_State     => GNAT.Secure_Hashes.SHA2_64.Hash_State,
   Initial_State  => GNAT.Secure_Hashes.SHA2_64.SHA384_Init_State,
   Transform      => GNAT.Secure_Hashes.SHA2_64.Transform);
