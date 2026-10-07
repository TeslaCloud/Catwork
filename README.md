# Catwork

A rather old and probably broken version of Clockwork that TeslaCloud Studios (Luna, AleXXX_007 and others) used to maintain.

Original code was written by [Conna Wiles](https://github.com/kurozael), [Alexander Grist-Hucker](https://github.com/alexgrist) and [Igor Radovanovic](https://github.com/impulsh), with contributions from the Cloud Sixteen community, credits for which [you may find in the original repository of Clockwork](https://github.com/CloudSixteen/Clockwork).

This code is probably broken. Use at your own risk.

## Binary modules

Not shipped with this repository. Use the build that matches your server: `win32` / `linux` for 32-bit, `win64` / `linux64` for 64-bit.

- `gmsv_file_*.dll` ([Meow/gmsv_file](https://github.com/Meow/gmsv_file)) in `garrysmod/lua/bin`.
- MySQLOO v9 `gmsv_mysqloo_*.dll` ([FredyH/MySQLOO](https://github.com/FredyH/MySQLOO)) in `garrysmod/lua/bin`. If your build comes with a `libmysql.dll`, it goes into the server root (next to `srcds`).

The old `catio`, `fileio` and `watchdog` modules are gone and no longer needed.
