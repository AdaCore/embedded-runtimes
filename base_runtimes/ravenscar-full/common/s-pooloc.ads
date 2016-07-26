------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                    S Y S T E M . P O O L _ L O C A L                     --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2011, Free Software Foundation, Inc.         --
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

--  Storage pool for use with local objects with automatic reclaim

with System.Storage_Elements;
with System.Pool_Global;

package System.Pool_Local is
   pragma Elaborate_Body;
   --  Needed to ensure that library routines can execute allocators

   ----------------------------
   -- Unbounded_Reclaim_Pool --
   ----------------------------

   --  Allocation strategy:

   --    Call to malloc/free for each Allocate/Deallocate
   --    No user specifiable size
   --    Space of allocated objects is reclaimed at pool finalization
   --    Manages a list of allocated objects

   type Unbounded_Reclaim_Pool is new
     System.Pool_Global.Unbounded_No_Reclaim_Pool with
       record
          First : System.Address := Null_Address;
       end record;

   --  function Storage_Size is inherited

   procedure Allocate
     (Pool         : in out Unbounded_Reclaim_Pool;
      Address      : out System.Address;
      Storage_Size : System.Storage_Elements.Storage_Count;
      Alignment    : System.Storage_Elements.Storage_Count);

   procedure Deallocate
     (Pool         : in out Unbounded_Reclaim_Pool;
      Address      : System.Address;
      Storage_Size : System.Storage_Elements.Storage_Count;
      Alignment    : System.Storage_Elements.Storage_Count);

   procedure Finalize (Pool : in out Unbounded_Reclaim_Pool);

end System.Pool_Local;
