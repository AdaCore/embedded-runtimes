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
with Interfaces;
with System.Storage_Elements;

package body Memory_Protection is
   use Kinetis_K64F.MPU;
   use Interfaces;
   use System.Storage_Elements;

   procedure Set_Mpu_Region_For_Cpu (
      Region_Index : Region_Index_Type;
      First_Address : System.Address;
      Last_Address : System.Address;
      Permissions : Bus_Master_Permissions_Type1)
      with Pre => Region_Index /= 0
                  and
                  To_Integer (First_Address) < To_Integer (Last_Address)
                  and
                  To_Integer (First_Address) mod MPU_Region_Alignment = 0
                  and
                  (To_Integer (Last_Address) + 1) mod MPU_Region_Alignment = 0;
   --
   --  Configure an MPU region (region index must be non 0, as region 0 is
   --  special) to cover a given range of addresses, to be accessible from
   --  the CPU, with the given access permissions
   --

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

   --  Start address of the text section in flash
   Flash_Text_Start : constant Unsigned_32;
   pragma Import (Asm, Flash_Text_Start, "__flash_text_start");

   --  End address of the text section in flash
   Flash_Text_End : constant Unsigned_32;
   pragma Import (Asm, Flash_Text_End, "__flash_text_end");

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      CESR_Value : CESR_Register_Type;
      WORD3_Value : WORD3_Register_Type;
      Read_Execute_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 1,
                                    Write_Allowed => 0,
                                    Read_Allowed => 1),
          others => <>);

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
         --  Set region 1 to be the code in flash:
         --
         Set_Mpu_Region_For_Cpu (
            1,
            Flash_Text_Start'Address,
            To_Address (To_Integer (Flash_Text_End'Address) - 1),
            Read_Execute_Permissions);

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

   ----------------------------
   -- Set_Mpu_Region_For_Cpu --
   ----------------------------

   procedure Set_Mpu_Region_For_Cpu (
      Region_Index : Region_Index_Type;
      First_Address : System.Address;
      Last_Address : System.Address;
      Permissions : Bus_Master_Permissions_Type1)
   is
      WORD2_Value : WORD2_Register_Type;
   begin
      --
      --  Configure region:
      --
      --  NOTE: writing to registers WORD0, WORD1 and WORD2 of the region
      --  descriptor for region 'Region_Index' will disable access to
      --  the region (turn off bit MPU_WORD_VLD_MASK in register WORD3):
      --

      MPU_Registers.Region_Descriptors (Region_Index).WORD0 :=
         Unsigned_32 (To_Integer (First_Address));

      MPU_Registers.Region_Descriptors (Region_Index).WORD1 :=
          Unsigned_32 (To_Integer (Last_Address));

      WORD2_Value := MPU_Registers.Region_Descriptors (Region_Index).WORD2;
      WORD2_Value.Master0 := Permissions;
      MPU_Registers.Region_Descriptors (Region_Index).WORD2 := WORD2_Value;

      --
      --  Re-enable access to the region:
      --
      MPU_Registers.Region_Descriptors (Region_Index).WORD3 :=
         (VLD => 1, others => <>);
   end Set_Mpu_Region_For_Cpu;

end Memory_Protection;
