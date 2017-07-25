[![Build status](https://ci.appveyor.com/api/projects/status/github/adacore/embedded-runtimes?svg=true)](https://ci.appveyor.com/project/github-integration-adacore/embedded-runtimes)

# embedded-runtimes

This repository contains runtimes that add support for various boards to the
GNAT GPL 2017 compiler for ARM and Aarch64.

## Content

Those runtimes can be either runtimes updated from the ones delivered with the
compiler, or new ones.

* Cortex M runtimes:
  - stm32f4: targetting the stm32f407, and compatible with most stm32f4 targets
    if not necessarily optimal.
  - stm32f429disco/stm32f469disco: optimized for the STM32F429/469 Discovery
    boards.
  - stm32f746disco/stm32f769disco: optimized for the STM32F7* Discovery boards.
  - openmv2: optimized for the OpenMV2 board.
  - sam4s: targetting the ATMEL SAM4S Xplained Pro board
  - samg55: targetting the ATMEL SAMG55 Xplained Pro board
  - smartfusion2: targetting the MicroSemi SF2 Starter Kit
  - lm3s: targetting the Texas Instruments LM3S MCU.

* Cortex A runtimes
  - zynq7000: for Xilinx Zynq7k based boards
  - rpi2: for the Raspberry PI2 board

* Cortex A 64-bit runtimes
  - rpi3: for the Raspberry PI3 board. Requires a AArch64 compiler.

## Installation

Make sure that GNAT GPL (targeting ARM or AARCH64) is in your PATH, and then
just invoke:

    $ cd embedded-runtimes
    $ make all
    $ make install

This will install the runtimes in your GNAT GPL compiler directory.

You can also install the runtimes individually:

    $ cd embedded-runtimes/bsps
    $ gprbuild -P ravenscar_sfp_stm32f769disco.gpr
    $ gprinstall -P ravenscar_sfp_st32f769disco.gpr -f -p

## Usage

To use such runtimes, you can specify it via the command line like:

    $ gprbuild --RTS=ravenscar-sfp-stm32f769disco -P <my_project>

or add in your project:

    for Runtime ("Ada") use "ravenscar-sfp-stm32f769disco";
