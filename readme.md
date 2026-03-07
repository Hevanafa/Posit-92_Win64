#

Posit-92 native Windows port based on the WebAssembly version

## Boilerplate

`DEMOS\hello_simple` is the boilerplate that is always up-to-date with the experimental features

`boilerplate` is the version that is usable with the current stable version

## How To Turn Off Debugging Console

To turn off the debugging console / terminal, follow this:
1. Open **Project > Project Settings**
2. Scroll down, find **Compiler Options**
3. Click **Config and Target**
4. Turn on **Win32 gui application**
5. Press **OK**

## Compiler Setup

Using `fpcupdeluxe` is recommended, but if you want to install FPC manually, it's up to you

1. Enable FPC version: Either **trunk** or **3.3.1** works

2. Then, click **Only FPC**

This process should take a few minutes

After that, install the cross compiler for:

x64:

- CPU: x86_64
- OS: windows

x86 (32-bit):

- CPU: i386
- OS: windows
