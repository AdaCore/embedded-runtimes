------------------------------------------------------------------------------
--                                                                          --
--                         GNAT LIBRARY COMPONENTS                          --
--                                                                          --
--                      G N A T . S E M A P H O R E S                       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                     Copyright (C) 2003-2010, AdaCore                     --
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
-- It is now maintained by Ada Core Technologies Inc (http://www.gnat.com). --
--                                                                          --
------------------------------------------------------------------------------

package body GNAT.Semaphores is

   ------------------------
   -- Counting_Semaphore --
   ------------------------

   protected body Counting_Semaphore is

      -----------
      -- Seize --
      -----------

      entry Seize when Count > 0 is
      begin
         Count := Count - 1;
      end Seize;

      -------------
      -- Release --
      -------------

      procedure Release is
      begin
         Count := Count + 1;
      end Release;
   end Counting_Semaphore;

   ----------------------
   -- Binary_Semaphore --
   ----------------------

   protected body Binary_Semaphore is

      -----------
      -- Seize --
      -----------

      entry Seize when Available is
      begin
         Available := False;
      end Seize;

      -------------
      -- Release --
      -------------

      procedure Release is
      begin
         Available := True;
      end Release;
   end Binary_Semaphore;

end GNAT.Semaphores;
