------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                          S Y S T E M . F O R E                           --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2014, Free Software Foundation, Inc.         --
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

package body System.Fore is

   ----------
   -- Fore --
   ----------

   function Fore (Lo, Hi : Long_Long_Float) return Natural is
      T : Long_Long_Float := Long_Long_Float'Max (abs Lo, abs Hi);
      R : Natural;

   begin
      --  Initial value of 2 allows for sign and mandatory single digit

      R := 2;

      --  Loop to increase Fore as needed to include full range of values

      while T >= 10.0 loop
         T := T / 10.0;
         R := R + 1;
      end loop;

      return R;
   end Fore;
end System.Fore;
