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
with Kinetis_KL25Z;
with Kinetis_KL25Z.MCG;
with Kinetis_KL25Z.SIM;
with Interfaces.Bit_Types;

package body Microcontroller_Clocks is
   use Kinetis_KL25Z;
   use Interfaces.Bit_Types;

   subtype Crystal_Frequency_Hz_Type is
     Hertz_Type range 5_000_000 .. 10_000_000;
   subtype Pll_Divider_Type is Integer range 1 .. 25;
   subtype Pll_Multiplier_Type is Integer range 24 .. 50;

   Crystal_Frequency_Hz : constant Crystal_Frequency_Hz_Type := 8_000_000;
   Pll_Divider : constant Pll_Divider_Type := 4;
   Pll_Multiplier : constant Pll_Multiplier_Type := 24;

   --
   --  Iniitalize the microcontroller clocks
   --
   procedure Initialize is
      procedure Pll_Init;

      procedure Pll_Init is
         --  Initialize PLL
         --
         --  NOTE: PLL will be the source for MCG CLKOUT so the core, system,
         --  and flash clocks are derived from it
         C2_Value : MCG.C2_Type;
         C1_Value : MCG.C1_Type;
         C5_Value : MCG.C5_Type;
         C6_Value : MCG.C6_Type;
         SOPT2_Value : SIM.SOPT2_Type;
         S_Value : MCG.S_Type;
      begin
         --
         --  Configure the mcg_c2 register:
         --  the range value is determined by the external frequency. since the
         --  range parameter affects the frdiv divide value, it still needs to
         --  be set correctly even if the oscillator is not being used
         --
         C2_Value := MCG.Registers.C2;
         C2_Value.RANGE0 := 1;
         C2_Value.HGO0 := 0;
         C2_Value.EREFS0 := 1;
         MCG.Registers.C2 := C2_Value;

         --
         --  Select external oscillator and Reference Divider and clear IREFS
         --  to start ext osc:
         --  If IRCLK is required it must be enabled outside of this driver,
         --  existing state will be maintained CLKS=2, FRDIV=frdiv_val,
         --  IREFS=0, IRCLKEN=0, IREFSTEN=0
         --
         C1_Value := MCG.Registers.C1;
         C1_Value.CLKS := 2;
         C1_Value.FRDIV := 3;
         C1_Value.IREFS := 0;
         MCG.Registers.C1 := C1_Value;

         --
         --  If the external oscillator is used need to wait for OSCINIT to
         --  set:
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.OSCINIT0 /= 0;
         end loop;

         --  Wait for Reference clock Status bit to clear:
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.IREFST = 0;
         end loop;

         --  Wait for clock status bits to show clock source is ext ref clk
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.CLKST = 2;
         end loop;

         --
         --  Configure PLL:
         --
         --  NOTE: Now in FBE, it is recommended that the clock monitor
         --  is enabled when using an external clock as the clock
         --  source/reference.
         --
         C5_Value := MCG.Registers.C5;
         C5_Value.PRDIV0 := UInt5 (Pll_Divider - 1);
         MCG.Registers.C5 := C5_Value;
         C6_Value := MCG.Registers.C6;
         C6_Value.CME0 := 1;
         C6_Value.PLLS := 1;
         C6_Value.VDIV0 := UInt5 (Pll_Multiplier - 24);
         MCG.Registers.C6 := C6_Value;

         --  Wait for PLLST status bit to set:
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.PLLST /= 0;
         end loop;

         --  Wait for LOCK bit to set:
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.LOCK0 /= 0;
         end loop;

         --
         --  Now in PBE, clear CLKS to switch CLKS mux to select PLL as
         --  MCG_OUT:
         C1_Value := MCG.Registers.C1;
         C1_Value.CLKS := 0;
         MCG.Registers.C1 := C1_Value;

         --  Wait for clock status bits to update:
         loop
            S_Value := MCG.Registers.S;
            exit when S_Value.CLKST = 3;
         end loop;

         --
         --  Now in PEE, MCGOUT equals PLL output frequency.
         --  Select PLL as a clock source for various peripherals:
         --
         SOPT2_Value := SIM.Registers.SOPT2;
         SOPT2_Value.PLLFLLSEL := 1;
         SIM.Registers.SOPT2 := SOPT2_Value;
      end Pll_Init;

      SCGC5_Value : SIM.SCGC5_Type;
      CLKDIV1_Value : SIM.CLKDIV1_Type;

   begin -- Initialize
      pragma Assert (Crystal_Frequency_Hz < Cpu_Clock_Frequency);

      --
      --  Set the system dividers:
      --
      --  NOTE: This is not really needed, as these are the settings at reset
      --  time.
      --
      CLKDIV1_Value := (OUTDIV1 => 0,  --  divided by 1
                        OUTDIV4 => 1   --  divided by 2
                       );
      SIM.Registers.CLKDIV1 := CLKDIV1_Value;

      Pll_Init;

      --
      --  Enable clocks for all GPIO ports:
      --
      SCGC5_Value := SIM.Registers.SCGC5;
      SCGC5_Value.PORTA := 1;
      SCGC5_Value.PORTB := 1;
      SCGC5_Value.PORTC := 1;
      SCGC5_Value.PORTD := 1;
      SCGC5_Value.PORTE := 1;
      SIM.Registers.SCGC5 := SCGC5_Value;
   end Initialize;

   --
   --  Return the PLL frequency in Hz
   --
   function Get_Pll_Frequency_Hz return Pll_Frequency_Type is
      Prdiv : Natural;
      Vdiv : Natural;
      Pll_Freq : Pll_Frequency_Type;
      C5_Value : MCG.C5_Type;
      C6_Value : MCG.C6_Type;
   begin
      C5_Value := MCG.Registers.C5;
      Prdiv := Natural (C5_Value.PRDIV0) + 1;
      C6_Value := MCG.Registers.C6;
      Vdiv := Natural (C6_Value.VDIV0) + 24;
      Pll_Freq := (Natural (Crystal_Frequency_Hz) / Prdiv) * Vdiv;
      return Pll_Freq;
   end Get_Pll_Frequency_Hz;

end Microcontroller_Clocks;
