------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                     S Y S T E M . P O O L _ S I Z E                      --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2010, Free Software Foundation, Inc.          --
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

with System.Storage_Pools;
with System.Storage_Elements;

package System.Pool_Size is
   pragma Elaborate_Body;
   --  Needed to ensure that library routines can execute allocators

   ------------------------
   -- Stack_Bounded_Pool --
   ------------------------

   --  Allocation strategy:

   --    Pool is a regular stack array, no use of malloc
   --    user specified size
   --    Space of pool is globally reclaimed by normal stack management

   --  Used in the compiler for access types with 'STORAGE_SIZE rep. clause
   --  Only used for allocating objects of the same type.

   type Stack_Bounded_Pool
     (Pool_Size : System.Storage_Elements.Storage_Count;
      Elmt_Size : System.Storage_Elements.Storage_Count;
      Alignment : System.Storage_Elements.Storage_Count)
   is
      new System.Storage_Pools.Root_Storage_Pool with record
         First_Free        : System.Storage_Elements.Storage_Count;
         First_Empty       : System.Storage_Elements.Storage_Count;
         Aligned_Elmt_Size : System.Storage_Elements.Storage_Count;
         The_Pool          : System.Storage_Elements.Storage_Array
                                                       (1 .. Pool_Size);
      end record;

   overriding function Storage_Size
     (Pool : Stack_Bounded_Pool) return System.Storage_Elements.Storage_Count;

   overriding procedure Allocate
     (Pool         : in out Stack_Bounded_Pool;
      Address      : out System.Address;
      Storage_Size : System.Storage_Elements.Storage_Count;
      Alignment    : System.Storage_Elements.Storage_Count);

   overriding procedure Deallocate
     (Pool         : in out Stack_Bounded_Pool;
      Address      : System.Address;
      Storage_Size : System.Storage_Elements.Storage_Count;
      Alignment    : System.Storage_Elements.Storage_Count);

   overriding procedure Initialize (Pool : in out Stack_Bounded_Pool);

end System.Pool_Size;
