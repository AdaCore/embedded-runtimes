------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                  S Y S T E M . B Y T E _ S W A P P I N G                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                     Copyright (C) 2006-2012, AdaCore                     --
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

--  Intrinsic routines for byte swapping. These are used by the expanded code
--  (supporting alternative byte ordering), and by the GNAT.Byte_Swapping run
--  time package which provides user level routines for byte swapping.

package System.Byte_Swapping is

   pragma Pure;

   type U16 is mod 2**16;
   type U32 is mod 2**32;
   type U64 is mod 2**64;

   function Bswap_16 (X : U16) return U16;
   pragma Import (Intrinsic, Bswap_16, "__builtin_bswap16");

   function Bswap_32 (X : U32) return U32;
   pragma Import (Intrinsic, Bswap_32, "__builtin_bswap32");

   function Bswap_64 (X : U64) return U64;
   pragma Import (Intrinsic, Bswap_64, "__builtin_bswap64");

end System.Byte_Swapping;
