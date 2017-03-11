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

with System;

--
--  @summary Memory Protection Services
--
package Memory_Protection is

   --
   --  Number of global MPU regions
   --  NOTE: region 0 (background region) does not count as it is disabled.
   --
   Num_Global_MPU_Regions : constant := 2;

   --
   --  Index for the first task-specific MPU region
   --
   First_Task_MPU_Region_Index : constant := Num_Global_MPU_Regions + 1;

   --
   --  Number of task-private MPU data regions
   --
   Num_Task_MPU_Regions : constant := 4;

   type Task_Data_Region_Index_Type is (Stack_Region_Index,
                                        Component_Data_Region_Index,
                                        Parameter_Data_Region_Index,
                                        MMIO_Region_Index);

   for Task_Data_Region_Index_Type use (
      Stack_Region_Index => First_Task_MPU_Region_Index,
      Component_Data_Region_Index => First_Task_MPU_Region_Index + 1,
      Parameter_Data_Region_Index => First_Task_MPU_Region_Index + 2,
      MMIO_Region_Index => First_Task_MPU_Region_Index + 3);

   pragma Compile_Time_Error (
      Task_Data_Region_Index_Type'Enum_Rep (Task_Data_Region_Index_Type'Last) -
      First_Task_MPU_Region_Index + 1 > Num_Task_MPU_Regions,
      "Not enough MPU regions for tasks");

   type Task_Data_Region_Permisions_Type is (Read_Only,
                                             Read_Write);

   --
   --  Address range and permissions for a given task data rregion
   --
   type Task_Data_Region_Type is limited record
      First_Address : System.Address;
      Last_Address : System.Address;
      Permissions : Task_Data_Region_Permisions_Type;
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
      Stack_Region : Task_Data_Region_Type;
      Componet_Data_Region : Task_Data_Region_Type;
      Parameter_Data_Region : Task_Data_Region_Type;
      MMIO_Region : Task_Data_Region_Type;
   end record;

   procedure Disable_MPU;
   --
   --  Disable the MPU hardware
   --

   procedure Initialize;
   --
   --  Initializes memory protection unit
   --

   procedure Set_Task_Data_Region (
      Task_Data_Region_Index : Task_Data_Region_Index_Type;
      Task_Data_Region : Task_Data_Region_Type);

   procedure Unset_Task_Data_Region (
      Task_Data_Region_Index : Task_Data_Region_Index_Type);

end Memory_Protection;
