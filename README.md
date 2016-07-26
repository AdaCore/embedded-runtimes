# embedded-runtimes

This repository contains runtimes that add support for various boards to the GNAT GPL compiler.

Those runtimes can be either runtimes updated from the ones delivered with the compiler, or new ones.

To use such runtimes, in your project file, just reference them by their relative directory path:

   for Runtime("Ada") use Project'Project_Dir & "/../embedded-runtimes/ravenscar-sfp-stm32f769disco";
