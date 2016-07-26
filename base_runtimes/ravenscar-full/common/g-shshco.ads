------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--       G N A T . S E C U R E _ H A S H E S . S H A 2 _ C O M M O N        --
--                                                                          --
--                                 S p e c                                  --
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

--  This package provides supporting code for implementation of the following
--  secure hash functions described in FIPS PUB 180-3: SHA-224, SHA-256,
--  SHA-384, SHA-512. It contains the generic transform operation that is
--  common to the above four functions. The complete text of FIPS PUB 180-3
--  can be found at:
--    http://csrc.nist.gov/publications/fips/fips180-3/fips180-3_final.pdf

--  This is an internal unit and should not be used directly in applications.
--  Use GNAT.SHA* instead.

package GNAT.Secure_Hashes.SHA2_Common is

   Block_Words : constant := 16;
   --  All functions operate on blocks of 16 words

   generic
      with package Hash_State is new Hash_Function_State (<>);

      Rounds : Natural;
      --  Number of transformation rounds

      K : Hash_State.State;
      --  Constants used in the transform operation

      with function Sigma0 (X : Hash_State.Word) return Hash_State.Word is <>;
      with function Sigma1 (X : Hash_State.Word) return Hash_State.Word is <>;
      with function S0 (X : Hash_State.Word) return Hash_State.Word is <>;
      with function S1 (X : Hash_State.Word) return Hash_State.Word is <>;
      --  FIPS PUB 180-3 elementary functions

   procedure Transform
     (H_St : in out Hash_State.State;
      M_St : in out Message_State);

end GNAT.Secure_Hashes.SHA2_Common;
