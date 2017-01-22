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

with Kinetis_K64F.MPU;
with System.BB.Parameters;

package body Memory_Protection is
   use Kinetis_K64F.MPU;

   --
   --  Number of global MPU regions
   --
   Num_Global_MPU_Regions : constant := 4;

   --
   --  Number of task-private MPU data regions
   --
   Num_Task_MPU_Regions : constant := 4;

   Num_Mpu_Regions_Table : constant array (0 .. 2) of Natural :=
      (0 => 8,
       1 => 12,
       2 => 16);

   type Memory_Protection_Type is record
      Initialized : Boolean := False;
      Num_Regions : Natural := 0;
   end record;

   Memory_Protection_Var : Memory_Protection_Type;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      CESR_Value : CESR_Register_Type;
      WORD3_Value : WORD3_Register_Type;
   begin
      pragma Assert (not Memory_Protection_Var.Initialized);

      if System.BB.Parameters.Use_MPU then
         --
         --  Verify that the MPU has enough regions:
         --
         CESR_Value := MPU_Registers.CESR;
         pragma Assert (Natural (CESR_Value.NRGD) <=
                        Num_Mpu_Regions_Table'Last);

         Memory_Protection_Var.Num_Regions :=
            Num_Mpu_Regions_Table (Natural (CESR_Value.NRGD));

         pragma Assert (Memory_Protection_Var.Num_Regions >=
                        Num_Global_MPU_Regions + Num_Task_MPU_Regions);

         --
         --  Disable MPU to configure it:
         --
         MPU_Registers.CESR := (VLD => 0, others => <>);

         --
         --  Disable access to region 0 (background region) for all bus
         --  masters:
         --
         WORD3_Value := (VLD => 0, others => <>);
         MPU_Registers.Region_Descriptors (0).WORD3 := WORD3_Value;
      else
         --
         --  Disable the MPU:
         --
         MPU_Registers.CESR := (VLD => 0, others => <>);
      end if;

      --
      --  NOTE: access to background region will be disabled upon the first
      --  task context switch
      --
      Memory_Protection_Var.Initialized := True;
   end Initialize;

end Memory_Protection;
