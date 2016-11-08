------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--                 SYSTEM.BB.CPU_PRIMITIVES.MULTIPROCESSORS                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                     Copyright (C) 2010-2016, AdaCore                     --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion. GNARL is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- You should have received a copy of the GNU General Public License along  --
-- with this library; see the file COPYING3. If not, see:                   --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

pragma Restrictions (No_Elaboration_Code);

with System.Multiprocessors;

package System.BB.CPU_Primitives.Multiprocessors is
   pragma Preelaborate;

   procedure Poke_Handler;
   --  Handler for the Poke interrupt

   procedure Start_All_CPUs;
   pragma Export (C, Start_All_CPUs, "__gnat_start_slave_cpus");
   --  Start all CPUs

end System.BB.CPU_Primitives.Multiprocessors;
