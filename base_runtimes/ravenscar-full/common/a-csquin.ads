------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--               ADA.CONTAINERS.SYNCHRONIZED_QUEUE_INTERFACES               --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2011-2015, Free Software Foundation, Inc.         --
--                                                                          --
-- This specification is derived from the Ada Reference Manual for use with --
-- GNAT. The copyright notice above, and the license provisions that follow --
-- apply solely to the  contents of the part following the private keyword. --
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

generic
   type Element_Type is private;

package Ada.Containers.Synchronized_Queue_Interfaces is
   pragma Pure;

   type Queue is synchronized interface;

   procedure Enqueue
     (Container : in out Queue;
      New_Item  : Element_Type) is abstract
   with Synchronization => By_Entry;

   procedure Dequeue
     (Container : in out Queue;
      Element   : out Element_Type) is abstract
   with Synchronization => By_Entry;

   function Current_Use (Container : Queue) return Count_Type is abstract;

   function Peak_Use (Container : Queue) return Count_Type is abstract;

end Ada.Containers.Synchronized_Queue_Interfaces;
