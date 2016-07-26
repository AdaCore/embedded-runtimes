------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--     A D A . E X C E P T I O N S . I S _ N U L L _ O C C U R R E N C E    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2000-2009, Free Software Foundation, Inc.         --
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

--  This is a GNAT-specific child function of Ada.Exceptions. It provides
--  clearly missing functionality for its parent package, and most reasonably
--  would simply be an added function to that package, but this change cannot
--  be made in a conforming manner.

function Ada.Exceptions.Is_Null_Occurrence
  (X : Exception_Occurrence) return Boolean;
pragma Preelaborate (Ada.Exceptions.Is_Null_Occurrence);
--  This function yields True if X is Null_Occurrence, and False otherwise
