------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--                S Y S T E M . R E L A T I V E _ D E L A Y S               --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--             Copyright (C) 2016, Free Software Foundation, Inc.           --
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

--  This package implements relative delays on runtime without Ada.Calendar

--  Note: the compiler generates direct calls to this interface

package System.Relative_Delays is

   procedure Delay_For (D : Duration);
   --  Delay until an interval of length (at least) D seconds has passed, or
   --  the task is aborted to at least the current ATC nesting level. This is
   --  an abort completion point. The body of this procedure must perform all
   --  the processing required for an abort point.

end System.Relative_Delays;
