------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                   S Y S T E M . R A N D O M _ S E E D                    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2011-2012, Free Software Foundation, Inc.         --
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

--  This package provide a seed for pseudo-random number generation using
--  the clock.

--  There are two separate implementations of this package:
--  o  one based on Ada.Calendar
--  o  one based on Ada.Real_Time

--  This is required because Ada.Calendar cannot be used on Ravenscar, but
--  Ada.Real_Time drags in the whole tasking runtime on regular platforms.

with Interfaces;

package System.Random_Seed is

   function Get_Seed return Interfaces.Unsigned_64;
   --  Get a seed based on the clock

end System.Random_Seed;
