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
--  Note: This package cannot contain any elaboration code, since procedure
--  Initialize needs to be invoked from the startup code, before package
--  elaboration code is executed
--
pragma Restrictions (No_Elaboration_Code);

with System.Storage_Elements;
with Interfaces.Bit_Types;

--
--  @summary Memory Protection Services
--
package Memory_Protection is
   pragma Preelaborate;

   use System.Storage_Elements;
   use System;

   --
   --  MPU region alignment (in bytes)
   --
   MPU_Region_Alignment : constant := 32;

   --
   --  MPU regions assignment
   --
   type MPU_Region_Index_Type is (
      --
      --  Regions accessible by the CPU core only
      --  (CPU core is the bus master):
      --
      Background_Region,
      Global_Code_Region,
      Global_ISR_Stack_Region,
      Global_Interrupt_Vector_Table_Region,
      Task_Private_Stack_Data_Region,
      Task_Private_Component_Data_Region,
      Task_Private_Temp_Data_Region,

      --
      --  Regions accessible by the corresponding DMA-capable devices
      --  (DMA device is the bus master)
      --
      Dma_Device_ENET_Region1,
      Dma_Device_ENET_Region2,

      --
      --  Unused region descriptors
      --
      Unused_Region1,
      Unused_Region2,
      Unused_Region3);

   for MPU_Region_Index_Type use (Background_Region => 0,
                                  Global_Code_Region => 1,
                                  Global_ISR_Stack_Region => 2,
                                  Global_Interrupt_Vector_Table_Region => 3,
                                  Task_Private_Stack_Data_Region => 4,
                                  Task_Private_Component_Data_Region => 5,
                                  Task_Private_Temp_Data_Region => 6,
                                  Dma_Device_ENET_Region1 => 7,
                                  Dma_Device_ENET_Region2 => 8,
                                  Unused_Region1 => 9,
                                  Unused_Region2 => 10,
                                  Unused_Region3 => 11);

   type Data_Region_Permisions_Type is (None,
                                        Read_Only,
                                        Read_Write);

   --
   --  Address range and permissions for a given data region
   --
   type Data_Region_Type is record
      First_Address : System.Address;
      Last_Address : System.Address;
      Permissions : Data_Region_Permisions_Type := None;
   end record;

   --
   --  Task-specific MPU data regions
   --
   --  @field Stack_Region MPU region for the task's stack
   --  @field Component_Data_Region MPU region for global data of current
   --  component called by the task
   --  @field Temp_Data_Region MPU region to for temporary access to non-
   --  component data, such as input or output paramters passed by reference
   --  and that are not in the current component's data region nor in the
   --  current task's stack. It can also be aused for accessing MMIO registers.
   --
   type Task_Data_Regions_Type is limited record
      Stack_Region : Data_Region_Type;
      Component_Data_Region : Data_Region_Type;
      Temp_Data_Region : Data_Region_Type;
   end record;

   type Task_Data_Regions_Access_Type is access all Task_Data_Regions_Type;

   procedure Initialize;
   --
   --  Initializes memory protection unit
   --
   --  NOTE: This subprogram is called during Ada startup code, before global
   --  package elaboration is done.
   --

   function Is_Valid_Data_Region (Data_Region : Data_Region_Type)
      return Boolean;

   --
   --  Subprograms to be invoked only from the Ada runtime library
   --

   procedure Enable_Background_Data_Region;
   --  with Inline;

   procedure Disable_Background_Data_Region;
   --  with Inline;

   procedure Restore_Thread_MPU_Data_Regions (
      Thread_Data_Regions : Task_Data_Regions_Type);
   --
   --  NOTE: This subporgram is tobe invoked only from the Ada runtime's
   --  context switch code and with the background region enabled
   --

   procedure Save_Thread_MPU_Data_Regions (
      Thread_Data_Regions : out Task_Data_Regions_Type);
   --
   --  NOTE: This subporgram is tobe invoked only from the Ada runtime's
   --  context switch code and with the background region enabled
   --

   --
   --  Public interfaces to be invoked from applications
   --

   procedure Enable_MPU;
   --
   --  This subprogram should be invoked at the beginning of the main program
   --

   procedure Set_Component_Data_Region (
      New_Component_Data_Region : Data_Region_Type)
      with Pre => Is_Valid_Data_Region (New_Component_Data_Region);
      --  with Inline;

   procedure Set_Component_Data_Region (
      New_Component_Data_Region : Data_Region_Type;
      Old_Component_Data_Region : out Data_Region_Type)
      with Pre => Is_Valid_Data_Region (New_Component_Data_Region),
           Post => Is_Valid_Data_Region (Old_Component_Data_Region);
      --  with Inline;

   procedure Set_Component_Data_Region (
      Start_Address : System.Address;
      Size_In_Bytes : Integer_Address;
      Permissions : Data_Region_Permisions_Type;
      Old_Component_Data_Region : out Data_Region_Type)
      with Pre => Start_Address /= Null_Address and Size_In_Bytes > 0,
           Post => Is_Valid_Data_Region (Old_Component_Data_Region);
      --  with Inline;

   procedure Set_Temp_Data_Region (
      New_Temp_Data_Region : Data_Region_Type)
      with Pre => Is_Valid_Data_Region (New_Temp_Data_Region);
      --  with Inline;

   procedure Set_Temp_Data_Region (
      Start_Address : System.Address;
      Size_In_Bytes : Integer_Address;
      Permissions : Data_Region_Permisions_Type)
      with Pre => Start_Address /= Null_Address and Size_In_Bytes > 0;

   procedure Unset_Temp_Data_Region;

   type Bus_Master_Type is (Cpu_Core0,
                            Debugger,
                            Dma_Device_DMA_Engine,
                            Dma_Device_ENET,
                            Dma_Device_USB,
                            Dma_Device_SDHC,
                            Dma_Device_Master6,
                            Dma_Device_Master7);

   procedure Set_DMA_Data_Region (Data_Region_Index : MPU_Region_Index_Type;
                                  DMA_Master : Bus_Master_Type;
                                  Start_Address : System.Address;
                                  Size_In_Bytes : Integer_Address;
                                  Permissions : Data_Region_Permisions_Type)
      with Pre => DMA_Master in Dma_Device_DMA_Engine .. Dma_Device_Master7
                  and
                  Start_Address /= Null_Address and Size_In_Bytes > 0;

   function Last_Address (First_Address : System.Address;
                          Size_In_Bits : Integer_Address) return System.Address
   is (To_Address (To_Integer (First_Address) +
                   (Size_In_Bits / Interfaces.Bit_Types.Byte'Size) - 1))
   with Inline;

   procedure Dump_MPU_Region_Descriptors;

private

   function Is_Valid_Data_Region (Data_Region : Data_Region_Type)
      return Boolean is
   (Data_Region.Permissions /= None
    and
    To_Integer (Data_Region.First_Address) <
                   To_Integer (Data_Region.Last_Address)
    and
    To_Integer (Data_Region.First_Address) mod MPU_Region_Alignment = 0
    and
    (To_Integer (Data_Region.Last_Address) + 1) mod MPU_Region_Alignment = 0);

end Memory_Protection;
