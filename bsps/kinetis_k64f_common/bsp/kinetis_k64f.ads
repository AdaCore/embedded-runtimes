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

with System; use System;
with System.BB.Parameters;
with Interfaces; use Interfaces;
with Interfaces.Bit_Types; use Interfaces.Bit_Types;

--
--  @summary Parent package for rI/O egister definitions for the Kinetis K64F
--  (ARM Cortex M4F) microcontrollers from NXP.
--
package Kinetis_K64F is
   pragma Preelaborate;

   type Bytes_Array is array (Positive range <>) of Byte;

   subtype Two_Bits is UInt2;
   subtype Three_Bits is UInt3;
   subtype Four_Bits is UInt4;
   subtype Five_Bits is UInt5;
   subtype Six_Bits is UInt6;
   subtype Half_Word is Unsigned_16;

   type External_Interrupt_Type is
     (DMA0_IRQ,
      DMA1_IRQ,
      DMA2_IRQ,
      DMA3_IRQ,
      DMA4_IRQ,
      DMA5_IRQ,
      DMA6_IRQ,
      DMA7_IRQ,
      DMA8_IRQ,
      DMA9_IRQ,
      DMA10_IRQ,
      DMA11_IRQ,
      DMA12_IRQ,
      DMA13_IRQ,
      DMA14_IRQ,
      DMA15_IRQ,
      DMA_Error_IRQ,
      MCM_IRQ,
      FTFE_IRQ,
      Read_Collision_IRQ,
      LVD_LVW_IRQ,
      LLWU_IRQ,
      WDOG_EWM_IRQ,
      RNG_IRQ,
      I2C0_IRQ,
      I2C1_IRQ,
      SPI0_IRQ,
      SPI1_IRQ,
      I2S0_Tx_IRQ,
      I2S0_Rx_IRQ,
      UART0_LON_IRQ,
      UART0_RX_TX_IRQ,
      UART0_ERR_IRQ,
      UART1_RX_TX_IRQ,
      UART1_ERR_IRQ,
      UART2_RX_TX_IRQ,
      UART2_ERR_IRQ,
      UART3_RX_TX_IRQ,
      UART3_ERR_IRQ,
      ADC0_IRQ,
      CMP0_IRQ,
      CMP1_IRQ,
      FTM0_IRQ,
      FTM1_IRQ,
      FTM2_IRQ,
      CMT_IRQ,
      RTC_IRQ,
      RTC_Seconds_IRQ,
      PIT0_IRQ,
      PIT1_IRQ,
      PIT2_IRQ,
      PIT3_IRQ,
      PDB0_IRQ,
      USB0_IRQ,
      USBDCD_IRQ,
      Reserved71_IRQ,
      DAC0_IRQ,
      MCG_IRQ,
      LPTMR0_IRQ,
      PORTA_IRQ,
      PORTB_IRQ,
      PORTC_IRQ,
      PORTD_IRQ,
      PORTE_IRQ,
      SWI_IRQ,
      SPI2_IRQ,
      UART4_RX_TX_IRQ,
      UART4_ERR_IRQ,
      UART5_RX_TX_IRQ,
      UART5_ERR_IRQ,
      CMP2_IRQ,
      FTM3_IRQ,
      DAC1_IRQ,
      ADC1_IRQ,
      I2C2_IRQ,
      CAN0_ORed_Message_buffer_IRQ,
      CAN0_Bus_Off_IRQ,
      CAN0_Error_IRQ,
      CAN0_Tx_Warning_IRQ,
      CAN0_Rx_Warning_IRQ,
      CAN0_Wake_Up_IRQ,
      SDHC_IRQ,
      ENET_1588_Timer_IRQ,
      ENET_Transmit_IRQ,
      ENET_Receive_IRQ,
      ENET_Error_IRQ);

   pragma Compile_Time_Error
     (External_Interrupt_Type'Pos (DMA0_IRQ) /= 0,
      "First IRQ number must be 0");
   pragma Compile_Time_Error
     (External_Interrupt_Type'Pos (ENET_Error_IRQ) /=
      System.BB.Parameters.Number_Of_Interrupt_ID,
      "Last IRQ number is wrong");

end Kinetis_K64F;
