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

with System.Storage_Elements;
private with Kinetis_K64F.MPU;

--
--  @summary Memory Protection Services
--
package Memory_Protection is
   use System.Storage_Elements;

   --
   --  MPU regions assignment
   --
   type MPU_Region_Index_Type is (
      --
      --  Regions accessible by the CPU core only
      --  (CPU core is the bus master):
      --
      Background_Region,
      Global_Unprivileged_Code_Region,
      Task_Private_Stack_Region,
      Task_Private_Component_Data_Region,
      Task_Private_Parameter_Data_Region,
      Task_Private_MMIO_Region,

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
      Unused_Region3,
      Unused_Region4);

   for MPU_Region_Index_Type use (Background_Region => 0,
                                  Global_Unprivileged_Code_Region => 1,
                                  Task_Private_Stack_Region => 2,
                                  Task_Private_Component_Data_Region => 3,
                                  Task_Private_Parameter_Data_Region => 4,
                                  Task_Private_MMIO_Region => 5,
                                  Dma_Device_ENET_Region1 => 6,
                                  Dma_Device_ENET_Region2 => 7,
                                  Unused_Region1 => 8,
                                  Unused_Region2 => 9,
                                  Unused_Region3 => 10,
                                  Unused_Region4 => 11);

   type Data_Region_Permisions_Type is (Read_Only,
                                        Read_Write);

   --
   --  Address range and permissions for a given data region
   --
   type Data_Region_Type is limited record
      First_Address : System.Address;
      Last_Address : System.Address;
      Permissions : Data_Region_Permisions_Type;
   end record;

   --
   --  Task-specific MPU data regions
   --
   --  @field Stack_Region MPU region for the task's stack
   --  @field Component_Data_Region MPU region for global data of current
   --  component called by the task
   --  @field Parameter_Data_Region MPU region to access input
   --  or output paramters passed by reference and that are not in the current
   --  component's data region nor in the current task's stack.
   --  @field MMIO_Region : MPU region to access MMIO registers
   --
   type Task_Data_Regions_Type is limited record
      Stack_Region : Data_Region_Type;
      Component_Data_Region : Data_Region_Type;
      Parameter_Data_Region : Data_Region_Type;
      MMIO_Region : Data_Region_Type;
   end record;

   procedure Disable_MPU;
   --
   --  Disable the MPU hardware
   --

   function Initialized return Boolean
      with Inline;
   --  @private (Used only in contracts)

   procedure Initialize
      with Pre => not Initialized;
   --
   --  Initializes memory protection unit
   --

   function Is_Valid_Data_Region (Data_Region : Data_Region_Type)
      return Boolean;

   function Is_MPU_Region_In_Use (MPU_Region_Index : MPU_Region_Index_Type)
      return Boolean;

   type Bus_Master_Type is (Cpu_Core0,
                            Debugger,
                            Dma_Device_DMA_Engine,
                            Dma_Device_ENET,
                            Dma_Device_USB,
                            Dma_Device_SDHC,
                            Dma_Device_Master6,
                            Dma_Device_Master7);

   procedure Define_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type;
      Bus_Master : Bus_Master_Type;
      Data_Region : Data_Region_Type)
      with Pre => Initialized
                  and
                  Data_Region_Index > Global_Unprivileged_Code_Region
                  and
                  not Is_MPU_Region_In_Use (Data_Region_Index)
                  and
                  Bus_Master /= Debugger
                  and
                  Is_Valid_Data_Region (Data_Region);
   --
   --  Defines a data region in the MPU to be accessible by the bus master
   --  associated with the corresponding MPU region index.
   --  The region will be accessible only by the given bus master,
   --  unless it overlaps with other regions defined in the MPU.
   --

   procedure Undefine_MPU_Data_Region (
      Data_Region_Index : MPU_Region_Index_Type)
      with Pre => Initialized
           and
           Data_Region_Index > Global_Unprivileged_Code_Region
           and
           Is_MPU_Region_In_Use (Data_Region_Index);
   --
   --  Undefines the given data region in the MPU. After this, all further
   --  accesses to the corresponding address range will cause bus fault
   --  exceptions.
   --

   --
   --  Public interfaces to be invoke dform applications
   --

   procedure Define_DMA_Data_Region (Data_Region_Index : MPU_Region_Index_Type;
                                     DMA_Master : Bus_Master_Type;
                                     Start_Address : System.Address;
                                     Size_In_Bytes : Integer_Address;
                                     Is_Read_Only : Boolean := False)
      with Pre =>
              Initialized
              and
              DMA_Master in Dma_Device_DMA_Engine .. Dma_Device_Master7;

private
   use Kinetis_K64F.MPU;

   function Is_Valid_Data_Region (Data_Region : Data_Region_Type)
      return Boolean is
   (To_Integer (Data_Region.First_Address) <
                     To_Integer (Data_Region.Last_Address)
                  and
                  To_Integer (Data_Region.First_Address) mod
                     MPU_Region_Alignment = 0
                  and
                  (To_Integer (Data_Region.Last_Address) + 1) mod
                     MPU_Region_Alignment = 0);

end Memory_Protection;
