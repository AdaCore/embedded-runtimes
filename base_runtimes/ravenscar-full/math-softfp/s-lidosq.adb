------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                S Y S T E M . L I B M _ S I N G L E . S Q R T             --
--                                                                          --
--                                B o d y                                   --
--                                                                          --
--           Copyright (C) 2014-2015, Free Software Foundation, Inc.        --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- You should have received a copy of the GNU General Public License along  --
-- with this library; see the file COPYING3. If not, see:                   --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This is the Ada Cert Math specific implementation of sqrt (powerpc)

with Ada.Unchecked_Conversion;

with System.Machine_Code;

package body System.Libm_Single.Squareroot is

   function Rsqrt (X : Float) return Float;
   --  Compute the reciprocal square root. There are two reasons for computing
   --  the reciprocal square root instead of computing directly the square
   --  root: PowerPc provides an instruction (fsqrte) to compute an estimate of
   --  the reciprocal (with 5 bits of precision), and the Newton-Raphson method
   --  is more efficient on the reciprocal than on the direct root (because the
   --  direct root needs divisions, while the reciprocal does not). Note that
   --  PowerPc core e300 doesn't support the direct square root operation.

   -----------
   -- Rsqrt --
   -----------

   function Rsqrt (X : Float) return Float is
      X_Half : constant Float := X * 0.5;
      Y, Y1  : Float;

   begin
      if Standard'Target_Name = "powerpc-elf" then

         --  On powerpc, the precision of fsqrte is at least 5 binary digits

         System.Machine_Code.Asm ("frsqrte %0,%1",
                                  Outputs => Float'Asm_Output ("=f", Y),
                                  Inputs  => Float'Asm_Input ("f", X));
      else
         --  Provide the exact result for 1.0

         if X = 1.0 then
            return X;
         end if;

         declare
            type Unsigned is mod 2**32;

            function To_Unsigned is new Ada.Unchecked_Conversion
              (Float, Unsigned);
            function From_Unsigned is new Ada.Unchecked_Conversion
              (Unsigned, Float);
            U : Unsigned;

         begin
            U := To_Unsigned (X);
            U := 16#5f3759df# - (U / 2);
            Y := From_Unsigned (U);

            --  Precision is 4 binary digits (but the next iteration is
            --  much better)
         end;
      end if;

      --  Refine: 10 digits (PowerPc) or 8 digits (fast method)

      Y := Y * (1.5 - X_Half * Y * Y);

      --  Refine: 20 digits (PowerPc) or 16 digits (fast method)

      Y := Y * (1.5 - X_Half * Y * Y);

      --  Refine (beyond the precision of Float)

      Y1 := Y * (1.5 - X_Half * Y * Y);

      if Y = Y1 then
         return Y1;
      else
         Y := Y1;
      end if;

      --  Empirical tests show the above iterations are inadequate in some
      --  cases and that two more iterations are needed to converge. Other
      --  algorithms may need to be explored. ???

      Y1 := Y * (1.5 - X_Half * Y * Y);

      if Y = Y1 then
         return Y1;
      else
         Y := Y1;
      end if;

      Y := Y * (1.5 - X_Half * Y * Y);

      --  This algorithm doesn't always provide exact results. For example,
      --  Sqrt (25.0) /= 5.0 exactly (it's wrong in the last bit).

      return Y;
   end Rsqrt;

   ----------
   -- Sqrt --
   ----------

   function Sqrt (X : Float) return Float is
   begin
      if X <= 0.0 then
         if X = 0.0 then
            return X;
         else
            return NaN;
         end if;

      elsif not Float'Machine_Overflows and then X = Infinity then
         --  Note that if Machine_Overflow is True Infinity won't return.
         --  But in that case, we can assume that X is not infinity.
         return X;

      else
         return X * Rsqrt (X);
      end if;
   end Sqrt;
end System.Libm_Single.Squareroot;
