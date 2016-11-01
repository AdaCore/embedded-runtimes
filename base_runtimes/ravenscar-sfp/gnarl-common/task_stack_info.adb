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
with System.Tasking; use System.Tasking;
with System.Task_Primitives.Operations;
with System.Storage_Elements; use System.Storage_Elements;

package body Task_Stack_Info is

   Environment_Task_Stack_Start : constant Unsigned_32;
   pragma Import (Asm, Environment_Task_Stack_Start, "__stack_start");

   Environment_Task_Stack_End : constant Unsigned_32;
   pragma Import (Asm, Environment_Task_Stack_End, "__stack_end");

   procedure Get_Current_Task_Stack (Stack_Address : out Address;
                                     Stack_Size : out Unsigned_32) is
      Calling_Task : constant Task_Id :=
        Task_Primitives.Operations.Self;
   begin
      if Calling_Task = Task_Primitives.Operations.Environment_Task then
         Stack_Address := Environment_Task_Stack_Start'Address;
         Stack_Size := Unsigned_32 (
                          To_Integer (Environment_Task_Stack_End'Address) -
                          To_Integer (Environment_Task_Stack_Start'Address));
      else
         Stack_Address :=
           Calling_Task.Common.Compiler_Data.Pri_Stack_Info.Start_Address;

         Stack_Size :=
           Unsigned_32 (Calling_Task.Common.Compiler_Data.Pri_Stack_Info.Size);
      end if;
   end Get_Current_Task_Stack;

end Task_Stack_Info;
