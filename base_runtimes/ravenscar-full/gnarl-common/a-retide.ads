------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                   A D A . R E A L _ T I M E . D E L A Y S                --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--          Copyright (C) 1992-2009, Free Software Foundation, Inc.         --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
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
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
------------------------------------------------------------------------------

--  Implements Real_Time.Time absolute delays

--  Note: the compiler generates direct calls to this interface, in the
--  processing of time types.

package Ada.Real_Time.Delays is

   function To_Duration (T : Real_Time.Time) return Duration;
   --  Convert Time to Duration

   procedure Delay_Until (T : Time);
   --  Delay until Clock has reached (at least) time T,
   --  or the task is aborted to at least the current ATC nesting level.
   --  The body of this procedure must perform all the processing
   --  required for an abort point.

end Ada.Real_Time.Delays;
