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

pragma Restrictions (No_Elaboration_Code);
pragma Ada_2012;

--
--  @summary Register definitions for the Kinetis K64F's MPU hardware block
--
package Kinetis_K64F.MPU is
   pragma Preelaborate;
   pragma SPARK_Mode (Off);

   --  MPU region alignment in bytes
   MPU_Region_Alignment : constant := 32;

   --  Control/Error Status Register
   type CESR_Register_Type is record
      --  Valid
      VLD            : Bit := 16#1#;
      --  unspecified
      Reserved_1_7   : Seven_Bits := 16#0#;
      --  Read-only. Number Of Region Descriptors
      NRGD           : Four_Bits := 16#1#;
      --  Read-only. Number Of Slave Ports
      NSP            : Four_Bits := 16#5#;
      --  Read-only. Hardware Revision Level
      HRL            : Four_Bits := 16#1#;
      --  unspecified
      Reserved_20_26 : Seven_Bits := 16#8#;
      --  Slave Port n Error
      SPERR          : Five_Bits := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CESR_Register_Type use record
      VLD            at 0 range 0 .. 0;
      Reserved_1_7   at 0 range 1 .. 7;
      NRGD           at 0 range 8 .. 11;
      NSP            at 0 range 12 .. 15;
      HRL            at 0 range 16 .. 19;
      Reserved_20_26 at 0 range 20 .. 26;
      SPERR          at 0 range 27 .. 31;
   end record;

   --  Error Detail Register, slave port n
   type EDR_Register_Type is record
      --  Read-only. Error Read/Write
      ERW   : Bit;
      --  Read-only. Error Attributes
      EATTR : Three_Bits;
      --  Read-only. Error Master Number
      EMN   : Four_Bits;
      --  Read-only. Error Process Identification
      EPID  : Byte;
      --  Read-only. Error Access Control Detail
      EACD  : Half_Word;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for EDR_Register_Type use record
      ERW   at 0 range 0 .. 0;
      EATTR at 0 range 1 .. 3;
      EMN   at 0 range 4 .. 7;
      EPID  at 0 range 8 .. 15;
      EACD  at 0 range 16 .. 31;
   end record;

   type Slave_Port_Type is record
      --  Error Address Register, slave port n
      EAR        : Word;
      --  Error Detail Register, slave port n
      EDR        : EDR_Register_Type;
   end record with Volatile, Size => 64;

   for Slave_Port_Type use record
      EAR   at 0 range 0 .. 31;
      EDR   at 4 range 0 .. 31;
   end record;

   type Slave_Port_Array_Type is array (0 .. 4) of Slave_Port_Type
      with Size => 320;

   --  Region Descriptor n, Word 0
   subtype Start_Address_Type is Unsigned_32
      with Dynamic_Predicate =>
         Start_Address_Type mod MPU_Region_Alignment = 0;

   subtype WORD0_Register_Type is Start_Address_Type;

   subtype End_Address_Type is Unsigned_32
      with Dynamic_Predicate =>
         (End_Address_Type + 1) mod MPU_Region_Alignment = 0;

   --  Region Descriptor n, Word 1
   subtype WORD1_Register_Type is End_Address_Type;

   type User_Mode_Permissions_Type is record
      Execute_Allowed : Bit := 2#0#;
      Write_Allowed : Bit := 2#0#;
      Read_Allowed : Bit := 2#0#;
   end record with Size => 3;

   for User_Mode_Permissions_Type use record
      Execute_Allowed at 0 range 0 .. 0;
      Write_Allowed   at 0 range 1 .. 1;
      Read_Allowed    at 0 range 2 .. 2;
   end record;

   type Supervisor_Mode_Permissions_Type is
     (Read_Write_Execute_Allowed,
      Only_Read_Execute_Allowed,
      Only_Read_Write_Allowed,
      Use_User_Mode_Permissions)
     with Size => 2;

   for Supervisor_Mode_Permissions_Type use
     (Read_Write_Execute_Allowed => 2#00#,
      Only_Read_Execute_Allowed => 2#01#,
      Only_Read_Write_Allowed => 2#10#,
      Use_User_Mode_Permissions => 2#11#);

   type Bus_Master_Permissions_Type1 is record
      User_Mode_Permissions : User_Mode_Permissions_Type;
      Supervisor_Mode_Permissions : Supervisor_Mode_Permissions_Type :=
         Use_User_Mode_Permissions;
      Process_Id_Enabled : Bit := 0;
   end record with Size => 6;

   for Bus_Master_Permissions_Type1 use record
      User_Mode_Permissions       at 0 range 0 .. 2;
      Supervisor_Mode_Permissions at 0 range 3 .. 4;
      Process_Id_Enabled          at 0 range 5 .. 5;
   end record;

   type Bus_Master_Permissions_Type2 is record
      Write_Allowed : Bit := 2#0#;
      Read_Allowed : Bit := 2#0#;
   end record with Size => 2;

   for Bus_Master_Permissions_Type2 use record
      Write_Allowed   at 0 range 0 .. 0;
      Read_Allowed    at 0 range 1 .. 1;
   end record;

   type Bus_Masters_Permissions_Type is record
      Bus_Master_CPU_Core_Perms : Bus_Master_Permissions_Type1;
      Bus_Master_Debugger_Perms : Bus_Master_Permissions_Type1;
      Bus_Master_DMA_EZport_Perms : Bus_Master_Permissions_Type1;
      Bus_Master_ENET_Perms : Bus_Master_Permissions_Type1;
      Bus_Master_USB_Perms : Bus_Master_Permissions_Type2;
      Bus_Master_SDHC_Perms : Bus_Master_Permissions_Type2;
      Bus_Master6_Perms : Bus_Master_Permissions_Type2;
      Bus_Master7_Perms : Bus_Master_Permissions_Type2;
   end record with Volatile_Full_Access, Size => Unsigned_32'Size,
                   Bit_Order => System.Low_Order_First;

   for Bus_Masters_Permissions_Type use record
      Bus_Master_CPU_Core_Perms at 0 range 0 .. 5;
      Bus_Master_Debugger_Perms at 0 range 6 .. 11;
      Bus_Master_DMA_EZport_Perms at 0 range 12 .. 17;
      Bus_Master_ENET_Perms at 0 range 18 .. 23;
      Bus_Master_USB_Perms at 0 range 24 .. 25;
      Bus_Master_SDHC_Perms at 0 range 26 .. 27;
      Bus_Master6_Perms at 0 range 28 .. 29;
      Bus_Master7_Perms at 0 range 30 .. 31;
   end record;

   --  Region Descriptor n, Word 2
   subtype WORD2_Register_Type is Bus_Masters_Permissions_Type;

   --  Region Descriptor n, Word 3
   type WORD3_Register_Type is record
      --  Valid
      VLD           : Bit := 2#0#;
      --  unspecified
      Reserved_1_15 : Fifteen_Bits := 16#0#;
      --  Process Identifier Mask
      PIDMASK       : Byte := 16#0#;
      --  Process Identifier
      PID           : Byte := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for WORD3_Register_Type use record
      VLD           at 0 range 0 .. 0;
      Reserved_1_15 at 0 range 1 .. 15;
      PIDMASK       at 0 range 16 .. 23;
      PID           at 0 range 24 .. 31;
   end record;

   type Region_Descriptor_Type is record
      WORD0 : WORD0_Register_Type;
      WORD1 : WORD1_Register_Type;
      WORD2 : WORD2_Register_Type;
      WORD3 : WORD3_Register_Type;
   end record with Volatile, Size => 16 * Byte'Size;

   for Region_Descriptor_Type use record
      WORD0 at 0  range 0 .. 31;
      WORD1 at 4  range 0 .. 31;
      WORD2 at 8  range 0 .. 31;
      WORD3 at 12 range 0 .. 31;
   end record;

   type Region_Index_Type is range 0 .. 11;

   --  Region descriptors
   type Region_Descriptors_Array_Type is
      array (Region_Index_Type) of Region_Descriptor_Type
      with Size => 12 * 4 * Unsigned_32'Size;

   --  Region Descriptor Alternate Access Control n
   subtype RGDAAC_Register_Type is Bus_Masters_Permissions_Type;

   --  Region Descriptor Alternate Access Control n
   type Alternate_Region_Descriptor_Array_Type is
      array (Region_Index_Type) of RGDAAC_Register_Type
      with Size => 12 * Unsigned_32'Size;

   --  Memory protection unit
   type MPU_Registers_Type is record
      --  Control/Error Status Register
      CESR               : CESR_Register_Type;
      --  slave ports
      Slave_Ports        : Slave_Port_Array_Type;
      --  Region Descriptors
      Region_Descriptors : Region_Descriptors_Array_Type;
      --  Region Descriptor Alternate Access Control n
      RGDAAC             : Alternate_Region_Descriptor_Array_Type;
   end record
     with Volatile;

   for MPU_Registers_Type use record
      CESR                at 0 range 0 .. 31;
      Slave_Ports         at 16 range 0 .. 319;
      Region_Descriptors  at 1024 range 0 .. 1535;
      RGDAAC              at 2048 range 0 .. 383;
   end record;

   --  Memory protection unit
   MPU_Registers : aliased MPU_Registers_Type
     with Import, Address => System'To_Address (16#4000D000#);

end Kinetis_K64F.MPU;
