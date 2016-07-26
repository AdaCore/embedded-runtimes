------------------------------------------------------------------------------
--                                                                          --
--                       S Y S T E M . C . E R R N O                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                     Copyright (C) 2010-2011, AdaCore                     --
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

package System.C.Errno is
   pragma Preelaborate;

   function Get_Errno_Addr return Address;
   pragma Export (C, Get_Errno_Addr, "__errno");
   --  Return the address of the (per thread) errno variable.
   --  Note that this is not used by the runtime (only referenced by libm),
   --  and therefore the current implementation may not be thread safe.
end System.C.Errno;
