------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--    S Y S T E M . M U L T I P R O C E S S O R S . S P I N _ L O C K S     --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                    Copyright (C) 2010-2016, AdaCore                      --
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

--  This version is for ARM bareboard targets that have ARMv6-M-based CPU cores
--  (i.e., Cortex-M0+), which only use a subset of Thumb2 instructions.
--
--  TODO: This file is a copy of
--  base_runtimes/ravenscar-sfp/gnarl-common/s-musplo.adb, with the Assembly
--  code modified to use only ARMv6-M instructions. To avoid code duplication
--  the original file should be refactored to move the Assembly code to a
--  separate file.

with Interfaces; use Interfaces;
with System.Machine_Code; use System.Machine_Code;

package body System.Multiprocessors.Spin_Locks is

   function Are_Interrupts_Disabled return Boolean;

   ----------
   -- Lock --
   ----------

   procedure Lock (Slock : in out Spin_Lock) is
      Succeeded : Boolean;

   begin
      --  Loop until we can get the lock

      loop
         Try_Lock (Slock, Succeeded);
         exit when Succeeded;
      end loop;
   end Lock;

   ------------
   -- Locked --
   ------------

   function Locked (Slock : Spin_Lock) return Boolean is
   begin
      return Slock.Flag /= Unlocked;
   end Locked;

   -----------------------------
   -- Are_Interrupts_Disabled --
   -----------------------------

   function Are_Interrupts_Disabled return Boolean is
      PRIMASK_Value : Unsigned_32;
   begin
      Asm ("mrs %0, primask",
           Outputs => Unsigned_32'Asm_Output ("=g", PRIMASK_Value),
           Volatile => True);

      return (PRIMASK_Value and 16#1#) /= 0;
   end Are_Interrupts_Disabled;

   --------------
   -- Try_Lock --
   --------------

   procedure Try_Lock (Slock : in out Spin_Lock; Succeeded : out Boolean) is

      function Lock_Test_And_Set
        (Ptr   : access Atomic_Flag;
         Value : Atomic_Flag)
         return Atomic_Flag;

      -----------------------
      -- Lock_Test_And_Set --
      -----------------------

      function Lock_Test_And_Set
        (Ptr   : access Atomic_Flag;
         Value : Atomic_Flag)
         return Atomic_Flag is
         --
         --  Implementation of Lock_Test_and_Set for Cortex-M0+ disabling
         --  interrupts as Cortex-M0+ does not have the LDREX/STREX
         --  instructions.
         --
         Interrupts_Disabled_Before : constant Boolean :=
           Are_Interrupts_Disabled;
         Value_Before : Atomic_Flag;
      begin
         if not Interrupts_Disabled_Before then
            --  Disable Interrupts in the ARM core:
            Asm ("cpsid i", Volatile => True);
         end if;

         Value_Before := Ptr.all;
         if Value_Before = Unlocked then
            Ptr.all := Value;
         end if;

         if not Interrupts_Disabled_Before then
            --  Enable Interrupts in the ARM core:
            Asm ("cpsie i" & ASCII.LF & ASCII.HT
                 & "dsb"   & ASCII.LF & ASCII.HT
                 & "isb",
                 Clobber => "memory", Volatile => True);
         end if;

         return Value_Before;
      end Lock_Test_And_Set;

   begin -- Try_Lock
      Succeeded := (Lock_Test_And_Set (Slock.Flag'Access, 1) = Unlocked);
   end Try_Lock;

   ------------
   -- Unlock --
   ------------

   procedure Unlock (Slock : in out Spin_Lock) is

      procedure Lock_Release (Ptr : access Atomic_Flag);

      procedure Lock_Release (Ptr : access Atomic_Flag) is
         --
         --  Implementation of Lock_Release for Cortex-M0+ disabling
         --  interrupts as Cortex-M0+ does not have the LDREX/STREX
         --  instructions.
         --
         Interrupts_Disabled_Before : constant Boolean :=
           Are_Interrupts_Disabled;
      begin
         if not Interrupts_Disabled_Before then
            --  Disable Interrupts in the ARM core:
            Asm ("cpsid i", Volatile => True);
         end if;

         Ptr.all := Unlocked;

         if not Interrupts_Disabled_Before then
            --  Enable Interrupts in the ARM core:
            Asm ("cpsie i" & ASCII.LF & ASCII.HT
                 & "dsb"   & ASCII.LF & ASCII.HT
                 & "isb",
                 Clobber => "memory", Volatile => True);
         end if;
      end Lock_Release;

   begin -- Unlock
      --  Clear Flag. This is a release barrier: all previous memory load
      --  are satisfied before this write access.

      Lock_Release (Slock.Flag'Access);
   end Unlock;

end System.Multiprocessors.Spin_Locks;
