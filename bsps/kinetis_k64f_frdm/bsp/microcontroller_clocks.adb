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
with Kinetis_K64F.PORT;
with Kinetis_K64F.MCG;
with Kinetis_K64F.SIM;
with Kinetis_K64F.PMC;
with Kinetis_K64F.OSC;
with Interfaces.Bit_Types;

package body Microcontroller_Clocks is
   use Kinetis_K64F;
   use Interfaces.Bit_Types;

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
         REGSC_Value : PMC.REGSC_Type;
         SOPT2_Value : SIM.SOPT2_Type;
         SOPT1_Value : SIM.SOPT1_Type;
         PCR_Value : PORT.PCR_Type;
         C7_Value : MCG.C7_Type;
         C4_Value : MCG.C4_Type;
         CLKDIV2_Value : SIM.CLKDIV2_Type;
      begin
         --  If ACKISO is set you must clear ackiso before initializing the
         --  PLL:
         REGSC_Value := PMC.Registers.REGSC;
         if REGSC_Value.ACKISO /= 0 then
            --  Clear bit by setting it (w1c):
            REGSC_Value.ACKISO := 1;
            PMC.Registers.REGSC := REGSC_Value;
         end if;

         --  Select PLL as a clock source for various peripherals:
         SOPT2_Value := SIM.Registers.SOPT2;
         SOPT2_Value.PLLFLLSEL := 1;
         SIM.Registers.SOPT2 := SOPT2_Value;

         --  LPO 1kHz oscillator drives 32 kHz clock for various peripherals
         SOPT1_Value := SIM.Registers.SOPT1;
         SOPT1_Value.OSC32KSEL := 3;
         SIM.Registers.SOPT1 := SOPT1_Value;

         PCR_Value := PORT.PortA_Registers.PCR (18);
         PCR_Value.ISF := 0;
         PCR_Value.MUX := 0;
         PORT.PortA_Registers.PCR (18) := PCR_Value;

         --  Switch to FBE Mode
         MCG.Registers.C2 := (C2_RANGE => 2, others => 0);

         OSC.Registers.CR := (ERCLKEN => 1, others => 0);

         C7_Value := MCG.Registers.C7;
         C7_Value.OSCSEL := 0;
         MCG.Registers.C7 := C7_Value;

         --  Select external reference clock
         MCG.Registers.C1 := (CLKS => 2, FRDIV => 5, IRCLKEN => 1,
                              others => 0);

         C4_Value := MCG.Registers.C4;
         C4_Value.DMX32 := 0;
         C4_Value.DRST_DRS := 0;
         MCG.Registers.C4 := C4_Value;

         MCG.Registers.C5 := (PRDIV0 => 16#13#, others => 0);

         MCG.Registers.C6 := (VDIV0 => 16#18#, others => 0);

         --  Check that the source of the FLL reference clock is the external
         --  reference clock:
         loop
            exit when MCG.Registers.S.IREFST = 0;
         end loop;

         --  Wait until external reference clock is selected as MCG output:
         loop
            exit when MCG.Registers.S.CLKST = 2#10#;
         end loop;

         --  Switch to PBE Mode:
         MCG.Registers.C6 := (PLLS => 1, VDIV0 => 16#18#, others => 0);

         --  Wait until external reference clock is selected as MCG output:
         loop
            exit when MCG.Registers.S.CLKST = 2#10#;
         end loop;

         --  Wait until locked:
         loop
            exit when MCG.Registers.S.LOCK0 /= 0;
         end loop;

         --  Switch to PEE Mode:
         MCG.Registers.C1 := (FRDIV => 5, IRCLKEN => 1, CLKS => 0,
                              others => 0);

         --  Wait until output of the PLL is selected:
         loop
            exit when MCG.Registers.S.CLKST = 2#11#;
         end loop;

         --  Set USB input clock to 48MHz:
         CLKDIV2_Value := SIM.Registers.CLKDIV2;
         CLKDIV2_Value.USBDIV := 4;
         CLKDIV2_Value.USBFRAC := 1;
         SIM.Registers.CLKDIV2 := CLKDIV2_Value;
      end Pll_Init;

      SCGC5_Value : SIM.SCGC5_Type;

   begin -- Initialize

      --  Enable all of the GPIO port clocks:
      SCGC5_Value := SIM.Registers.SCGC5;
      SCGC5_Value.PORTA := 1;
      SCGC5_Value.PORTB := 1;
      SCGC5_Value.PORTC := 1;
      SCGC5_Value.PORTD := 1;
      SCGC5_Value.PORTE := 1;
      SIM.Registers.SCGC5 := SCGC5_Value;

      --  Set the system dividers:
      --
      --  Core clock: MCG CLKOUT divided by OUTDIV1
      --  System clock: MCG CLKOUT divided by OUTDIV1
      --  Bus clock: MCG CLKOUT divided by OUTDIV2
      --
      --  NOTE: To see which clocks are used for which devices see table 5-2,
      --  page 191, section 5.7, K64 Sub-Family Reference Manual
      SIM.Registers.CLKDIV1 := (OUTDIV1 => 0,  --  divided by 1
                                OUTDIV2 => 1,  --  divided by 2
                                OUTDIV3 => 2,  --  divided by 3
                                OUTDIV4 => 4   --  divided by 5
                               );

      Pll_Init;

   end Initialize;

end Microcontroller_Clocks;
