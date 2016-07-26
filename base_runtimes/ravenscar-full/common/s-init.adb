------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                             S Y S T E M . I N I T                        --
--                                                                          --
--                                   B o d y                                --
--                                                                          --
--          Copyright (C) 2003-2014, Free Software Foundation, Inc.         --
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
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
------------------------------------------------------------------------------

--  This is a bare board implementation of this package

with System.BB.CPU_Primitives;
with System.BB.Parameters;     use System.BB.Parameters;
with System.Tasking;

package body System.Init is

   ------------------------
   --  Local procedures  --
   ------------------------

   --  These procedures are called by the binder.

   procedure Initialize;
   pragma Export (C, Initialize, "__gnat_initialize");

   procedure Finalize;
   pragma Export (C, Finalize, "__gnat_finalize");

   --------------
   -- Finalize --
   --------------

   procedure Finalize is
   begin
      null;
   end Finalize;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      null;
   end Initialize;

   ---------------------
   -- Install_Handler --
   ---------------------

   procedure Install_Handler is
   begin
      BB.CPU_Primitives.Install_Error_Handlers;
   end Install_Handler;

   ------------------------
   -- Runtime_Initialize --
   ------------------------

   procedure Runtime_Initialize is
   begin
      --  Ensure that the tasking run time is initialized when using this run
      --  time. This initialization is required by the support for exceptions
      --  (which uses thread local storage). The initialization routine has the
      --  required machinery to prevent multiple calls to Initialize.

      System.Tasking.Initialize;

      Install_Handler;
   end Runtime_Initialize;

   ----------------------
   -- Runtime_Finalize --
   ----------------------

   procedure Runtime_Finalize is
   begin
      null;
   end Runtime_Finalize;
end System.Init;
