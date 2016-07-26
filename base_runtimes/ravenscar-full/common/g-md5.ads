------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--                             G N A T . M D 5                              --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--           Copyright (C) 2009-2010, Free Software Foundation, Inc.        --
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

--  This package implements the MD5 Message-Digest Algorithm as described in
--  RFC 1321. The complete text of RFC 1321 can be found at:
--          http://www.ietf.org/rfc/rfc1321.txt

--  See the declaration of GNAT.Secure_Hashes.H in g-sechas.ads for complete
--  documentation.

with GNAT.Secure_Hashes.MD5;
with System;

package GNAT.MD5 is new GNAT.Secure_Hashes.H
  (Block_Words    => GNAT.Secure_Hashes.MD5.Block_Words,
   State_Words    => 4,
   Hash_Words     => 4,
   Hash_Bit_Order => System.Low_Order_First,
   Hash_State     => GNAT.Secure_Hashes.MD5.Hash_State,
   Initial_State  => GNAT.Secure_Hashes.MD5.Initial_State,
   Transform      => GNAT.Secure_Hashes.MD5.Transform);
