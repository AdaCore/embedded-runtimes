--
--  Copyright (c) 2016, German Rivera
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--
--  * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
--  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
--  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
--  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--

with System.Text_IO.Extended;
with System.BB.CPU_Primitives;
with Interfaces;
with System.Machine_Code;
with System.Storage_Elements;

package body Cpu_Exception_Handlers is
   use Interfaces;

   procedure Common_Cpu_Exception_Handler (Msg : String;
                                           Return_Address : Unsigned_32)
      with Inline, No_Return;

   function Get_LR_Register return Unsigned_32 with Inline_Always;

   function Get_PSP_Register return Unsigned_32 with Inline;

   ----------------------------------
   -- Common_Cpu_Exception_Handler --
   ----------------------------------

   procedure Common_Cpu_Exception_Handler (Msg : String;
                                           Return_Address : Unsigned_32) is
   begin
      System.BB.CPU_Primitives.Disable_Interrupts;
      System.Text_IO.Extended.Put_String (Msg & ASCII.LF);

      if Return_Address = 16#FFFFFFFD# or else
         Return_Address = 16#FFFFFFED#
      then
         --
         --  The code where the exception was triggered was using the PSP stack
         --  pointer, so the offending code was a task
         --
         declare
            use System.Storage_Elements;
            Stack : array (0 .. 6) of Unsigned_32 with Address =>
                       To_Address (Integer_Address (Get_PSP_Register));
            PC_At_Exception : constant Unsigned_32  := Stack (6);
         begin
            System.Text_IO.Extended.Put_String (
               "Code address where fault happened:" & PC_At_Exception'Image &
               ASCII.LF);
         end;
      else
         System.Text_IO.Extended.Put_String (
            "Fault happened in an ISR (Return Address" &
            Return_Address'Image & ")" & ASCII.LF);
      end if;

      loop
         null;
      end loop;
   end Common_Cpu_Exception_Handler;

   ---------------------
   -- Get_LR_Register --
   ---------------------

   function Get_LR_Register return Unsigned_32 is
      Reg_Value : Unsigned_32;
   begin
      System.Machine_Code.Asm (
         "mov %0, lr",
         Outputs => Interfaces.Unsigned_32'Asm_Output ("=r", Reg_Value),
         Volatile => True);

      return Reg_Value;
   end Get_LR_Register;

   ----------------------
   -- Get_PSP_Register --
   ----------------------

   function Get_PSP_Register return Unsigned_32 is
      Reg_Value : Unsigned_32;
   begin
      System.Machine_Code.Asm (
         "mrs %0, psp",
         Outputs => Interfaces.Unsigned_32'Asm_Output ("=r", Reg_Value),
         Volatile => True);
      return Reg_Value;
   end Get_PSP_Register;

   ------------------------
   -- Hard_Fault_Handler --
   ------------------------

   procedure Hard_Fault_Handler is
      Return_Address : constant Unsigned_32 := Get_LR_Register;
   begin
      Common_Cpu_Exception_Handler ("*** Hard Fault ***", Return_Address);
   end Hard_Fault_Handler;

end Cpu_Exception_Handlers;
