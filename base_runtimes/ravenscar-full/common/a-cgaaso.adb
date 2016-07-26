------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--              ADA.CONTAINERS.GENERIC_ANONYMOUS_ARRAY_SORT                 --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 2004-2011, Free Software Foundation, Inc.         --
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
-- This unit was originally developed by Matthew J Heaney.                  --
------------------------------------------------------------------------------

--  This unit was originally a GNAT-specific addition to Ada 2005. A unit
--  providing the same feature, Ada.Containers.Generic_Sort, was defined for
--  Ada 2012.  We retain Generic_Anonymous_Array_Sort for compatibility, but
--  implement it in terms of the official unit, Generic_Sort.

with Ada.Containers.Generic_Sort;

procedure Ada.Containers.Generic_Anonymous_Array_Sort
  (First, Last : Index_Type'Base)
is
   procedure Sort is new Ada.Containers.Generic_Sort
     (Index_Type => Index_Type,
      Before     => Less,
      Swap       => Swap);

begin
   Sort (First, Last);
end Ada.Containers.Generic_Anonymous_Array_Sort;
