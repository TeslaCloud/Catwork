# Catwork

A rather old and probably broken version of Clockwork that TeslaCloud Studios (Luna, AleXXX_007 and others) used to maintain.

Original code was written by [Conna Wiles](https://github.com/kurozael), [Alexander Grist-Hucker](https://github.com/alexgrist) and [Igor Radovanovic](https://github.com/impulsh), with contributions from the Cloud Sixteen community, credits for which [you may find in the original repository of Clockwork](https://github.com/CloudSixteen/Clockwork).

This code is probably broken. Use at your own risk.

## Binary modules

Not shipped with this repository. Use the build that matches your server: `win32` / `linux` for 32-bit, `win64` / `linux64` for 64-bit.

- `gmsv_file_*.dll` ([Meow/gmsv_file](https://github.com/Meow/gmsv_file)) in `garrysmod/lua/bin`.
- MySQLOO v9 `gmsv_mysqloo_*.dll` ([FredyH/MySQLOO](https://github.com/FredyH/MySQLOO)) in `garrysmod/lua/bin`. If your build comes with a `libmysql.dll`, it goes into the server root (next to `srcds`).

The old `catio`, `fileio` and `watchdog` modules are gone and no longer needed.

## License

Catwork © 2016-2017 TeslaCloud Studios. Please find the license under [LICENSE](LICENSE).

Original code by Alex Grist, 'impulse and Conna Wiles, with contributions from the Cloud Sixteen community.

This notice applies to every file in this repository, unless the file itself says otherwise.

Parts of Catwork are borrowed from [Flux](https://github.com/TeslaCloud/flux-ce), which is released under the [MIT License](https://github.com/TeslaCloud/flux-ce/blob/master/LICENSE).

Networking is done by two libraries vendored in `gamemodes/catwork/gamemode/thirdparty`, which keep their own notices:

- `cable.lua` ([Meow/cable](https://github.com/Meow/cable)) © 2018 TeslaCloud Studios, under the MIT License like the edition of it that [Flux](https://github.com/TeslaCloud/flux-ce) ships. The copy here is adapted for Catwork; the note at the top of the file lists the changes.
- `sfs.lua` ([Srlion/sfs](https://github.com/Srlion/sfs), version 7.0.9) © 2024 Srlion, under the [MIT License](https://github.com/Srlion/sfs/blob/master/LICENSE).
