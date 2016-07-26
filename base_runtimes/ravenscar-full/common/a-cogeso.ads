------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--                       ADA.CONTAINERS.GENERIC_SORT                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--            Copyright (C) 2011, Free Software Foundation, Inc.            --
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

--  Allows an anonymous array (or array-like container) to be sorted. Generic
--  formal Before returns the result of comparing the elements designated by
--  the indexes, and generic formal Swap exchanges the designated elements.

generic
   type Index_Type is (<>);
   with function Before (Left, Right : Index_Type) return Boolean;
   with procedure Swap (Left, Right : Index_Type);

procedure Ada.Containers.Generic_Sort (First, Last : Index_Type'Base);
pragma Pure (Ada.Containers.Generic_Sort);
