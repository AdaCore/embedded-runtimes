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

--
--  I dedicate this module to Luzmila
--

with System.BB.Parameters;
with System.Machine_Code;
with Kinetis_K64F.MPU;
with System.Text_IO.Extended;

package body Memory_Protection is
   use Interfaces.Bit_Types;
   use Interfaces;
   use Kinetis_K64F.MPU;
   use Machine_Code;

   pragma Compile_Time_Error (
      MPU_Region_Alignment /= Kinetis_K64F.MPU.MPU_Region_Alignment,
      "MPU region alignment must match hardware MPU");

   pragma Compile_Time_Error (
      MPU_Region_Index_Type'Enum_Rep (MPU_Region_Index_Type'First) <
      Kinetis_K64F.MPU.Region_Index_Type'First
      or
      MPU_Region_Index_Type'Enum_Rep (MPU_Region_Index_Type'Last) >
      Kinetis_K64F.MPU.Region_Index_Type'Last,
      "MPU_Region_Index_Type contains invalid region numbers");

   Num_Mpu_Regions_Table : constant array (0 .. 2) of Natural :=
      (0 => 8,
       1 => 12,
       2 => 16);

   type Memory_Protection_Type is record
      Initialized : Boolean := False;
      Num_Regions : Natural := 0;
      Enable_Background_Data_Region_Count : Unsigned_32 := 0 with Volatile;
   end record;

   Memory_Protection_Var : Memory_Protection_Type;

   --
   --  Linker-script symbols defined in
   --  embedded-runtimes/bsps/kinetis_k64f_common/bsp/common-ROM.ld
   --

   --  Start address of the text section in flash
   --  Flash_Text_Start : constant Unsigned_32;
   --  pragma Import (Asm, Flash_Text_Start, "__flash_text_start");

   --  End address of the text section in flash
   --  Flash_Text_End : constant Unsigned_32;
   --  pragma Import (Asm, Flash_Text_End, "__flash_text_end");

   --  End address of the rodata section in flash
   --  Rom_End : constant Unsigned_32;
   --  pragma Import (Asm, Rom_End, "__rom_end");

   --  Start address of the main stack (for ISRs)
   Main_Stack_Start : constant Unsigned_32;
   pragma Import (Asm, Main_Stack_Start, "__stack_start");

   --  End address of the main stack (for ISRs)
   Main_Stack_End : constant Unsigned_32;
   pragma Import (Asm, Main_Stack_End, "__stack_end");

   Interrupt_Vector_Table_Start : constant Unsigned_32;
   pragma Import (Asm, Interrupt_Vector_Table_Start, "__vectors");

   Interrupt_Vector_Table_End : constant Unsigned_32;
   pragma Import (Asm, Interrupt_Vector_Table_End, "__vectors_end");

   function Round_Down (Value : Integer_Address;
                        Alignment : Integer_Address)
                        return Integer_Address
      with Inline;

   function Round_Down_Address (Address : System.Address;
                                Alignment : Integer_Address)
                                return System.Address
      with Inline;

   function Round_Up (Value : Integer_Address;
                      Alignment : Integer_Address)
                      return Integer_Address
      with Inline;

   function Round_Up_Address (Address : System.Address;
                              Alignment : Integer_Address)
                              return System.Address
      with Inline;

   procedure Define_Mpu_Region (
      MPU_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      First_Address : System.Address;
      Last_Address : System.Address;
      Type1_Permissions : Bus_Master_Permissions_Type1;
      Type2_Permissions : Bus_Master_Permissions_Type2)
      with Pre => MPU_Region_Index >= Global_Code_Region;
   --
   --  Configure an MPU region to cover a given range of addresses and with
   --  the given access permissions, for the given bus master.
   --

   procedure Define_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      Data_Region : Data_Region_Type)
      with Pre => Memory_Protection_Var.Initialized
                  and
                  Data_Region_Index > Global_Code_Region
                  and
                  Bus_Master /= Debugger;
   --
   --  Defines a data region in the MPU to be accessible by the bus master
   --  associated with the corresponding MPU region index.
   --  The region will be accessible only by the given bus master,
   --  unless it overlaps with other regions defined in the MPU.
   --
   --  NOTE: This subprogram must be invoked with the background region enabled
   --

   procedure Capture_Mpu_Region (
      MPU_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      First_Address : out System.Address;
      Last_Address : out System.Address;
      Type1_Permissions : out Bus_Master_Permissions_Type1;
      Type2_Permissions : out Bus_Master_Permissions_Type2)
      with Pre => Memory_Protection_Var.Initialized
                  and
                  MPU_Region_Index > Global_Code_Region
                  and
                  Bus_Master /= Debugger;

   procedure Save_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      Data_Region : out Data_Region_Type)
      with Pre => Memory_Protection_Var.Initialized
                  and
                  Data_Region_Index > Global_Code_Region
                  and
                  Bus_Master /= Debugger;
   --
   --  Defines a data region in the MPU to be accessible by the bus master
   --  associated with the corresponding MPU region index.
   --  The region will be accessible only by the given bus master,
   --  unless it overlaps with other regions defined in the MPU.
   --
   --  NOTE: This subprogram must be invoked with the background region enabled
   --

   procedure Undefine_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type)
      with Pre => Memory_Protection_Var.Initialized
           and
           Data_Region_Index > Global_Code_Region;
   --
   --  Undefines the given data region in the MPU. After this, all further
   --  accesses to the corresponding address range will cause bus fault
   --  exceptions.
   --
   --  NOTE: This subprogram must be invoked with the background region enabled
   --

   function Disable_Cpu_Interrupts return Word;

   procedure Restore_Cpu_Interrupts (Old_Primask : Word);

   ------------------------
   -- Capture_Mpu_Region --
   ------------------------

   procedure Capture_Mpu_Region (
      MPU_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      First_Address : out System.Address;
      Last_Address : out System.Address;
      Type1_Permissions : out Bus_Master_Permissions_Type1;
      Type2_Permissions : out Bus_Master_Permissions_Type2)
   is
      WORD2_Value : WORD2_Register_Type;
      WORD3_Value : WORD3_Register_Type;
      Region_Index : constant Region_Index_Type := MPU_Region_Index'Enum_Rep;
      Old_Intr_Mask : Word;
   begin
      Old_Intr_Mask := Disable_Cpu_Interrupts;

      First_Address :=
         To_Address (Integer_Address (
            MPU_Registers.Region_Descriptors (Region_Index).WORD0));

      Last_Address :=
         To_Address (Integer_Address (
            MPU_Registers.Region_Descriptors (Region_Index).WORD1));

      Type1_Permissions := (others => <>);
      Type2_Permissions := (others => <>);

      WORD3_Value := MPU_Registers.Region_Descriptors (Region_Index).WORD3;
      if WORD3_Value.VLD = 1 then
         WORD2_Value := MPU_Registers.Region_Descriptors (Region_Index).WORD2;
         case Bus_Master is
            when Cpu_Core0 =>
               Type1_Permissions := WORD2_Value.Bus_Master_CPU_Core_Perms;
            when Dma_Device_DMA_Engine =>
               Type1_Permissions := WORD2_Value.Bus_Master_DMA_EZport_Perms;
            when Dma_Device_ENET =>
               Type1_Permissions := WORD2_Value.Bus_Master_ENET_Perms;
            when Dma_Device_USB =>
               Type2_Permissions := WORD2_Value.Bus_Master_USB_Perms;
            when Dma_Device_SDHC =>
               Type2_Permissions := WORD2_Value.Bus_Master_SDHC_Perms;
            when Dma_Device_Master6 =>
               Type2_Permissions := WORD2_Value.Bus_Master6_Perms;
            when Dma_Device_Master7 =>
               Type2_Permissions := WORD2_Value.Bus_Master7_Perms;
            when others =>
               pragma Assert (False);
         end case;
      end if;

      Restore_Cpu_Interrupts (Old_Intr_Mask);
   end Capture_Mpu_Region;

   -----------------------
   -- Define_Mpu_Region --
   -----------------------

   procedure Define_Mpu_Region (
      MPU_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      First_Address : System.Address;
      Last_Address : System.Address;
      Type1_Permissions : Bus_Master_Permissions_Type1;
      Type2_Permissions : Bus_Master_Permissions_Type2)
   is
      WORD2_Value : WORD2_Register_Type;
      WORD3_Value : WORD3_Register_Type;
      Region_Index : constant Region_Index_Type := MPU_Region_Index'Enum_Rep;
      Old_Intr_Mask : Word;
   begin
      Old_Intr_Mask := Disable_Cpu_Interrupts;

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

      case Bus_Master is
         when Cpu_Core0 =>
            WORD2_Value.Bus_Master_CPU_Core_Perms := Type1_Permissions;
         when Dma_Device_DMA_Engine =>
            WORD2_Value.Bus_Master_DMA_EZport_Perms := Type1_Permissions;
         when Dma_Device_ENET =>
            WORD2_Value.Bus_Master_ENET_Perms := Type1_Permissions;
         when Dma_Device_USB =>
            WORD2_Value.Bus_Master_USB_Perms := Type2_Permissions;
         when Dma_Device_SDHC =>
            WORD2_Value.Bus_Master_SDHC_Perms := Type2_Permissions;
         when Dma_Device_Master6 =>
            WORD2_Value.Bus_Master6_Perms := Type2_Permissions;
         when Dma_Device_Master7 =>
            WORD2_Value.Bus_Master7_Perms := Type2_Permissions;
         when others =>
            pragma Assert (False);
      end case;

      MPU_Registers.Region_Descriptors (Region_Index).WORD2 := WORD2_Value;

      --
      --  Re-enable access to the region:
      --
      WORD3_Value := MPU_Registers.Region_Descriptors (Region_Index).WORD3;
      WORD3_Value.VLD := 1;
      MPU_Registers.Region_Descriptors (Region_Index).WORD3 := WORD3_Value;

      System.Machine_Code.Asm ("isb", Volatile => True);
      Restore_Cpu_Interrupts (Old_Intr_Mask);
   end Define_Mpu_Region;

   ----------------------------
   -- Define_MPU_Data_Region --
   ----------------------------

   procedure Define_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      Data_Region : Data_Region_Type)
   is
      Type1_Read_Write_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 1,
                                    Read_Allowed => 1),
          others => <>);

      Type1_Read_Only_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 0,
                                    Read_Allowed => 1),
          others => <>);

      Type2_Read_Write_Permissions : constant Bus_Master_Permissions_Type2 :=
         (Write_Allowed => 1, Read_Allowed => 1);

      Type2_Read_Only_Permissions : constant Bus_Master_Permissions_Type2 :=
         (Write_Allowed => 0, Read_Allowed => 1);

      Type1_Permissions : Bus_Master_Permissions_Type1;
      Type2_Permissions : Bus_Master_Permissions_Type2;
   begin
      case Data_Region.Permissions is
         when Read_Only =>
            if Bus_Master <= Dma_Device_ENET then
               Type1_Permissions := Type1_Read_Only_Permissions;
            else
               Type2_Permissions := Type2_Read_Only_Permissions;
            end if;
         when Read_Write =>
            if Bus_Master <= Dma_Device_ENET then
               Type1_Permissions := Type1_Read_Write_Permissions;
            else
               Type2_Permissions := Type2_Read_Write_Permissions;
            end if;
         when others =>
            pragma Assert (False);
      end case;

      Define_Mpu_Region (
            Data_Region_Index,
            Bus_Master,
            Data_Region.First_Address,
            Data_Region.Last_Address,
            Type1_Permissions,
            Type2_Permissions);
   end Define_MPU_Data_Region;

   ------------------------------------
   -- Disable_Background_Data_Region --
   ------------------------------------

   procedure Disable_Background_Data_Region is
      RGDAAC_Value : RGDAAC_Register_Type;
      Old_Intr_Mask : Word;
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      pragma Assert (Memory_Protection_Var.Initialized);

      Old_Intr_Mask := Disable_Cpu_Interrupts;

      pragma Assert (Memory_Protection_Var.Initialized);
      pragma Assert (
         Memory_Protection_Var.Enable_Background_Data_Region_Count > 0);

      Memory_Protection_Var.Enable_Background_Data_Region_Count :=
         Memory_Protection_Var.Enable_Background_Data_Region_Count - 1;

      if Memory_Protection_Var.Enable_Background_Data_Region_Count = 0 then
         System.Machine_Code.Asm ("isb", Volatile => True);

         --
         --  NOTE: To disable the background region, we need to do so through
         --  the region's RGDAAC register instead of modifying the WORD2 or
         --  WORD3, as doing that for the background region will cause a bus
         --  fault.
         --
         RGDAAC_Value := MPU_Registers.RGDAAC (Background_Region'Enum_Rep);
         RGDAAC_Value.Bus_Master_CPU_Core_Perms.User_Mode_Permissions :=
            (Read_Allowed => 0, Write_Allowed => 0, Execute_Allowed => 0);
         MPU_Registers.RGDAAC (Background_Region'Enum_Rep) := RGDAAC_Value;
         System.Machine_Code.Asm ("isb", Volatile => True);
      end if;

      Restore_Cpu_Interrupts (Old_Intr_Mask);
   end Disable_Background_Data_Region;

   ----------------------------
   -- Disable_Cpu_Interrupts --
   ----------------------------

   function Disable_Cpu_Interrupts return Word is
      Reg_Value : Word;
   begin
      Asm ("mrs %0, primask" & ASCII.LF &
           "cpsid i" & ASCII.LF &
           "isb" & ASCII.LF,
           Outputs => Word'Asm_Output ("=r", Reg_Value),
           Volatile => True, Clobber => "memory");

      return Reg_Value;
   end Disable_Cpu_Interrupts;

   ---------------------------------
   -- Dump_MPU_Region_Descriptors --
   ---------------------------------

   procedure Dump_MPU_Region_Descriptors is
      Count : Unsigned_32; -- ???
   begin
      --  ???
      Count := Memory_Protection_Var.Enable_Background_Data_Region_Count;
      System.Text_IO.Extended.Put_String ("*** Count " & Count'Image &
         ASCII.LF);
      Count := Memory_Protection_Var.Enable_Background_Data_Region_Count;
      System.Text_IO.Extended.Put_String ("*** Count " & Count'Image &
         ASCII.LF);
      Count := Memory_Protection_Var.Enable_Background_Data_Region_Count;
      System.Text_IO.Extended.Put_String ("*** Count " & Count'Image &
         ASCII.LF);
      --  ???

      for I in Region_Index_Type loop
         declare
            Word0_Val : Unsigned_32 with Address =>
               MPU_Registers.Region_Descriptors (I).WORD0'Address;
            Word1_Val : Unsigned_32 with Address =>
               MPU_Registers.Region_Descriptors (I).WORD1'Address;
            Word2_Val : Unsigned_32 with Address =>
               MPU_Registers.Region_Descriptors (I).WORD2'Address;
            Word3_Val : Unsigned_32 with Address =>
               MPU_Registers.Region_Descriptors (I).WORD3'Address;
            RGDAAC_Val : Unsigned_32 with Address =>
               MPU_Registers.RGDAAC (I)'Address;
         begin
            System.Text_IO.Extended.Put_String ("*** Region" &
               I'Image & ": " &
               "Word0=" & Word0_Val'Image & ", " &
               "Word1=" & Word1_Val'Image & ", " &
               "Word2=" & Word2_Val'Image & ", " &
               "Word3=" & Word3_Val'Image & ", " &
               "RGDAAC=" & RGDAAC_Val'Image & ASCII.LF);
         end;
      end loop;

      --  ???
      Count := Memory_Protection_Var.Enable_Background_Data_Region_Count;
      System.Text_IO.Extended.Put_String ("*** Count " & Count'Image &
         ASCII.LF);
      --  ???

   end Dump_MPU_Region_Descriptors;

   -----------------------------------
   -- Enable_Background_Data_Region --
   -----------------------------------

   procedure Enable_Background_Data_Region is
      RGDAAC_Value : RGDAAC_Register_Type;
      Old_Intr_Mask : Word;
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      pragma Assert (Memory_Protection_Var.Initialized);

      Old_Intr_Mask := Disable_Cpu_Interrupts;

      RGDAAC_Value := MPU_Registers.RGDAAC (Background_Region'Enum_Rep);
      RGDAAC_Value.Bus_Master_CPU_Core_Perms.User_Mode_Permissions :=
         (Read_Allowed => 1, Write_Allowed => 1, Execute_Allowed => 0);
      MPU_Registers.RGDAAC (Background_Region'Enum_Rep) := RGDAAC_Value;
      System.Machine_Code.Asm ("isb", Volatile => True);

      pragma Assert (Memory_Protection_Var.Initialized);
      Memory_Protection_Var.Enable_Background_Data_Region_Count :=
         Memory_Protection_Var.Enable_Background_Data_Region_Count + 1;

      Restore_Cpu_Interrupts (Old_Intr_Mask);
   end Enable_Background_Data_Region;

   ----------------
   -- Enable_MPU --
   ----------------

   procedure Enable_MPU is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      pragma Assert (Memory_Protection_Var.Initialized);

      MPU_Registers.CESR := (VLD => 1, others => <>);
      System.Machine_Code.Asm ("isb", Volatile => True);
   end Enable_MPU;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Type1_Read_Execute_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 1,
                                    Write_Allowed => 0,
                                    Read_Allowed => 1),
          others => <>);

      Type1_Read_Write_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 1,
                                    Read_Allowed => 1),
          others => <>);

      Type1_Read_Only_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 0,
                                    Read_Allowed => 1),
          others => <>);

      CESR_Value : CESR_Register_Type;
      WORD2_Value : WORD2_Register_Type;
      WORD3_Value : WORD3_Register_Type;
      Dummy_Type2_Permissions : Bus_Master_Permissions_Type2;
   begin
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
                        MPU_Region_Index_Type'Enum_Rep (
                           MPU_Region_Index_Type'Last));

         --
         --  Disable MPU to configure it:
         --
         MPU_Registers.CESR := (VLD => 0, others => <>);

         --
         --  Disable access to all regions other than the background region:
         --
         WORD3_Value := (VLD => 0, others => <>);
         WORD2_Value := (others => <>);
         for I in Background_Region'Enum_Rep + 1 ..
                  Region_Index_Type'Last loop
            MPU_Registers.Region_Descriptors (I).WORD2 := WORD2_Value;
            MPU_Registers.Region_Descriptors (I).WORD3 := WORD3_Value;
         end loop;

         --
         --  Set global region for the code and contants in flash:
         --
         Define_Mpu_Region (
            Global_Code_Region,
            Cpu_Core0,
            --  Flash_Text_Start'Address,
            To_Address (Integer_Address (16#0#)),
            --  To_Address (To_Integer (Rom_End'Address) - 1),
            To_Address (Integer_Address (16#7ff_ffff#)),
            Type1_Read_Execute_Permissions,
            Dummy_Type2_Permissions);

         --
         --  Set MPU region for ISR stack:
         --
         Define_Mpu_Region (
            Global_ISR_Stack_Region,
            Cpu_Core0,
            To_Address (To_Integer (Main_Stack_Start'Address)),
            To_Address (To_Integer (Main_Stack_End'Address) - 1),
            Type1_Read_Write_Permissions,
            Dummy_Type2_Permissions);

         --
         --  Set MPU region for relocated interrupt vector in RAM stack:
         --
         Define_Mpu_Region (
            Global_Interrupt_Vector_Table_Region,
            Cpu_Core0,
            To_Address (To_Integer (Interrupt_Vector_Table_Start'Address)),
            To_Address (To_Integer (Interrupt_Vector_Table_End'Address) - 1),
            Type1_Read_Only_Permissions,
            Dummy_Type2_Permissions);

         --
         --  Disable access to the background region for all  masters
         --
         MPU_Registers.RGDAAC (Background_Region'Enum_Rep) := (others => <>);
         Memory_Protection_Var.Enable_Background_Data_Region_Count := 0;

         --
         --  NOTE: Leave the MPU disabled, so that the Ada runtime startup code
         --  and global package elaboration can execute normally.
         --  The application's main rpogram is expected to call Enable_MPU
         --
      else
         MPU_Registers.CESR := (VLD => 0, others => <>);
      end if;

      Memory_Protection_Var.Initialized := True;
   end Initialize;

   ----------------------------
   -- Restore_Cpu_Interrupts --
   ----------------------------

   procedure Restore_Cpu_Interrupts (Old_Primask : Word) is
   begin
      if (Old_Primask and 16#1#) = 0 then
         Asm ("isb" & ASCII.LF &
              "cpsie i" & ASCII.LF,
              Clobber => "memory",
              Volatile => True);
      end if;
   end Restore_Cpu_Interrupts;

   ----------------
   -- Round_Down --
   ----------------

   function Round_Down (Value : Integer_Address;
                        Alignment : Integer_Address)
                        return Integer_Address
   is ((Value / Alignment) * Alignment);

   ------------------------
   -- Round_Down_Address --
   ------------------------

   function Round_Down_Address (Address : System.Address;
                                Alignment : Integer_Address)
                                return System.Address
   is (To_Address (Round_Down (To_Integer (Address), Alignment)));

   --------------
   -- Round_Up --
   --------------

   function Round_Up (Value : Integer_Address;
                      Alignment : Integer_Address)
                      return Integer_Address
   is ((((Value - 1) / Alignment) + 1) * Alignment);

   ----------------------
   -- Round_Up_Address --
   ----------------------

   function Round_Up_Address (Address : System.Address;
                              Alignment : Integer_Address)
                              return System.Address
   is (To_Address (Round_Up (To_Integer (Address), Alignment)));

   -------------------------------------
   -- Restore_Thread_MPU_Data_Regions --
   -------------------------------------

   procedure Restore_Thread_MPU_Data_Regions (
      Thread_Data_Regions : Task_Data_Regions_Type)
   is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      pragma Assert (Memory_Protection_Var.Initialized);

      Define_MPU_Data_Region (
         Data_Region_Index => Task_Private_Stack_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => Thread_Data_Regions.Stack_Region);

      if  Thread_Data_Regions.Component_Data_Region.Permissions /= None then
         Define_MPU_Data_Region (
           Data_Region_Index => Task_Private_Component_Data_Region,
           Bus_Master => Cpu_Core0,
           Data_Region => Thread_Data_Regions.
                             Component_Data_Region);
      else
         Undefine_MPU_Data_Region (
            Data_Region_Index => Task_Private_Component_Data_Region);
      end if;

      if Thread_Data_Regions.Temp_Data_Region.Permissions /= None then
         Define_MPU_Data_Region (
           Data_Region_Index => Task_Private_Temp_Data_Region,
           Bus_Master => Cpu_Core0,
           Data_Region => Thread_Data_Regions.Temp_Data_Region);
      else
         Undefine_MPU_Data_Region (
            Data_Region_Index => Task_Private_Temp_Data_Region);
      end if;

      System.Machine_Code.Asm ("isb", Volatile => True);
   end Restore_Thread_MPU_Data_Regions;

   --------------------------
   -- Save_MPU_Data_Region --
   --------------------------

   procedure Save_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      Data_Region : out Data_Region_Type)
   is
      Type1_Read_Write_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 1,
                                    Read_Allowed => 1),
          others => <>);

      Type1_Read_Only_Permissions : constant Bus_Master_Permissions_Type1 :=
         (User_Mode_Permissions => (Execute_Allowed => 0,
                                    Write_Allowed => 0,
                                    Read_Allowed => 1),
          others => <>);

      Type2_Read_Write_Permissions : constant Bus_Master_Permissions_Type2 :=
         (Write_Allowed => 1, Read_Allowed => 1);

      Type2_Read_Only_Permissions : constant Bus_Master_Permissions_Type2 :=
         (Write_Allowed => 0, Read_Allowed => 1);

      Type1_Permissions : Bus_Master_Permissions_Type1;
      Type2_Permissions : Bus_Master_Permissions_Type2;
   begin
      Capture_Mpu_Region (
            Data_Region_Index,
            Bus_Master,
            Data_Region.First_Address,
            Data_Region.Last_Address,
            Type1_Permissions,
            Type2_Permissions);

      if Bus_Master <= Dma_Device_ENET then
         if Type1_Permissions = Type1_Read_Only_Permissions then
            Data_Region.Permissions := Read_Only;
         elsif Type1_Permissions = Type1_Read_Write_Permissions then
            Data_Region.Permissions := Read_Write;
         else
            Data_Region.Permissions := None;
         end if;
      else
         if Type2_Permissions = Type2_Read_Only_Permissions then
            Data_Region.Permissions := Read_Only;
         elsif Type2_Permissions = Type2_Read_Write_Permissions then
            Data_Region.Permissions := Read_Write;
         else
            Data_Region.Permissions := None;
         end if;
      end if;
   end Save_MPU_Data_Region;

   ----------------------------------
   -- Save_Thread_MPU_Data_Regions --
   ----------------------------------

   procedure Save_Thread_MPU_Data_Regions (
      Thread_Data_Regions : out Task_Data_Regions_Type)
   is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      pragma Assert (Memory_Protection_Var.Initialized);

      Save_MPU_Data_Region (
         Data_Region_Index => Task_Private_Stack_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => Thread_Data_Regions.Stack_Region);

      Save_MPU_Data_Region (
         Data_Region_Index => Task_Private_Component_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => Thread_Data_Regions.Component_Data_Region);

      Save_MPU_Data_Region (
         Data_Region_Index => Task_Private_Temp_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => Thread_Data_Regions.Temp_Data_Region);
   end Save_Thread_MPU_Data_Regions;

   -------------------------------
   -- Set_Component_Data_Region --
   -------------------------------

   procedure Set_Component_Data_Region (
      New_Component_Data_Region : Data_Region_Type)
   is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      Enable_Background_Data_Region;

      Define_MPU_Data_Region (
           Data_Region_Index => Task_Private_Component_Data_Region,
           Bus_Master => Cpu_Core0,
           Data_Region => New_Component_Data_Region);

      Disable_Background_Data_Region;
   end Set_Component_Data_Region;

   -------------------------------
   -- Set_Component_Data_Region --
   -------------------------------

   procedure Set_Component_Data_Region (
      New_Component_Data_Region : Data_Region_Type;
      Old_Component_Data_Region : out Data_Region_Type)
   is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      Enable_Background_Data_Region;
      Save_MPU_Data_Region (
         Data_Region_Index => Task_Private_Component_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => Old_Component_Data_Region);

      Define_MPU_Data_Region (
           Data_Region_Index => Task_Private_Component_Data_Region,
           Bus_Master => Cpu_Core0,
           Data_Region => New_Component_Data_Region);

      Disable_Background_Data_Region;
   end Set_Component_Data_Region;

   -------------------------------
   -- Set_Component_Data_Region --
   -------------------------------

   procedure Set_Component_Data_Region (
      Start_Address : System.Address;
      Size_In_Bytes : Integer_Address;
      Permissions : Data_Region_Permisions_Type;
      Old_Component_Data_Region : out Data_Region_Type)
   is
      New_Component_Data_Region : constant Data_Region_Type :=
         (First_Address => Round_Down_Address (Start_Address,
                                               MPU_Region_Alignment),
          Last_Address => To_Address (Round_Up (To_Integer (Start_Address) +
                                                Size_In_Bytes,
                                                MPU_Region_Alignment) - 1),
          Permissions => Permissions);
   begin
      Set_Component_Data_Region (New_Component_Data_Region,
                                 Old_Component_Data_Region);
   end Set_Component_Data_Region;

   -------------------------
   -- Set_DMA_Data_Region --
   -------------------------

   procedure Set_DMA_Data_Region (Data_Region_Index : MPU_Region_Index_Type;
                                  DMA_Master : Bus_Master_Type;
                                  Start_Address : System.Address;
                                  Size_In_Bytes : Integer_Address;
                                  Permissions : Data_Region_Permisions_Type)
   is
      Data_Region : constant Data_Region_Type :=
         (First_Address => Round_Down_Address (Start_Address,
                                               MPU_Region_Alignment),
          Last_Address => To_Address (Round_Up (To_Integer (Start_Address) +
                                                Size_In_Bytes,
                                                MPU_Region_Alignment) - 1),
          Permissions => Permissions);
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      Enable_Background_Data_Region;
      Define_MPU_Data_Region (Data_Region_Index, DMA_Master, Data_Region);
      Disable_Background_Data_Region;
   end Set_DMA_Data_Region;

   --------------------------
   -- Set_Temp_Data_Region --
   --------------------------

   procedure Set_Temp_Data_Region (
      New_Temp_Data_Region : Data_Region_Type) is
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      Enable_Background_Data_Region;

      Define_MPU_Data_Region (
         Data_Region_Index => Task_Private_Temp_Data_Region,
         Bus_Master => Cpu_Core0,
         Data_Region => New_Temp_Data_Region);

      Disable_Background_Data_Region;
   end Set_Temp_Data_Region;

   --------------------------
   -- Set_Temp_Data_Region --
   --------------------------

   procedure Set_Temp_Data_Region (
      Start_Address : System.Address;
      Size_In_Bytes : Integer_Address;
      Permissions : Data_Region_Permisions_Type)
   is
      New_Temp_Data_Region : constant Data_Region_Type :=
         (First_Address => Round_Down_Address (Start_Address,
                                               MPU_Region_Alignment),
          Last_Address => To_Address (Round_Up (To_Integer (Start_Address) +
                                                Size_In_Bytes,
                                                MPU_Region_Alignment) - 1),
          Permissions => Permissions);
   begin
      if not System.BB.Parameters.Use_MPU then
         return;
      end if;

      Enable_Background_Data_Region;

      Define_MPU_Data_Region (
           Data_Region_Index => Task_Private_Temp_Data_Region,
           Bus_Master => Cpu_Core0,
           Data_Region => New_Temp_Data_Region);

      Disable_Background_Data_Region;
   end Set_Temp_Data_Region;

   ------------------------------
   -- Undefine_MPU_Data_Region --
   ------------------------------

   procedure Undefine_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type)
   is
      Region_Index : constant Region_Index_Type :=
         Data_Region_Index'Enum_Rep;
   begin
      --
      --  Disable access to the region:
      --
      MPU_Registers.Region_Descriptors (Region_Index).WORD3 :=
         (VLD => 0, others => <>);
   end Undefine_MPU_Data_Region;

   ----------------------------
   -- Unset_Temp_Data_Region --
   ----------------------------

   procedure Unset_Temp_Data_Region is
   begin
      Undefine_MPU_Data_Region (Task_Private_Temp_Data_Region);
   end Unset_Temp_Data_Region;

end Memory_Protection;
