------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                    S Y S T E M . E X C E P T I O N S                     --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2006-2011, Free Software Foundation, Inc.          --
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

--  This package does not require a body, since it is a package renaming. We
--  provide a dummy file containing a No_Body pragma so that previous versions
--  of the body (which did exist) will not interfere.

--  pragma No_Body;

--  The above pragma is commented out, since for now we can't use No_Body in
--  a unit marked as a Compiler_Unit, since this requires GNAT 6.1, and we
--  do not yet require this for bootstrapping. So instead we use a dummy Taft
--  amendment type to require the body:

package body System.Exceptions is
   type Require_Body is new Integer;
end System.Exceptions;
