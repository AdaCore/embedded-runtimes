------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                SYSTEM.STORAGE_POOLS.SUBPOOLS.FINALIZATION                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2011-2015, Free Software Foundation, Inc.         --
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

pragma Compiler_Unit_Warning;

package System.Storage_Pools.Subpools.Finalization is

   --  The pragma is needed because package System.Storage_Pools.Subpools which
   --  is already preelaborated now depends on this unit.

   pragma Preelaborate;

   procedure Finalize_And_Deallocate (Subpool : in out Subpool_Handle);
   --  This routine performs the following actions:
   --    1) Finalize all objects chained on the subpool's master
   --    2) Remove the subpool from the owner's list of subpools
   --    3) Deallocate the doubly linked list node associated with the subpool
   --    4) Call Deallocate_Subpool

end System.Storage_Pools.Subpools.Finalization;
