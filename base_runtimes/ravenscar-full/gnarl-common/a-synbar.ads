------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--             A D A . S Y N C H R O N O U S _ B A R R I E R S              --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--          Copyright (C) 1992-2011, Free Software Foundation, Inc.         --
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
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

package Ada.Synchronous_Barriers is
   pragma Preelaborate (Synchronous_Barriers);

   subtype Barrier_Limit is Positive range 1 .. Positive'Last;

   type Synchronous_Barrier (Release_Threshold : Barrier_Limit) is
      limited private;

   procedure Wait_For_Release
     (The_Barrier : in out Synchronous_Barrier;
      Notified    : out Boolean);

private
   protected type Synchronous_Barrier (Release_Threshold : Barrier_Limit) is
      entry Wait (Notified : out Boolean);
   private
      Keep_Open : Boolean := False;
   end Synchronous_Barrier;
end Ada.Synchronous_Barriers;
