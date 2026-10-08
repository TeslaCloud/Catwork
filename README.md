# Catwork

A rather old and probably broken version of Clockwork that TeslaCloud Studios (Luna, AleXXX_007 and others) used to maintain.

Original code was written by [Conna Wiles](https://github.com/kurozael), [Alexander Grist-Hucker](https://github.com/alexgrist) and [Igor Radovanovic](https://github.com/impulsh), with contributions from the Cloud Sixteen community, credits for which [you may find in the original repository of Clockwork](https://github.com/CloudSixteen/Clockwork).

This code is probably broken. Use at your own risk.

## Docker (easy mode)

If you have Docker and simply want a running server, the `Dockerfile` in this repository does the setup for you: it installs the x86-64 Garry's Mod dedicated server, downloads the binary modules listed below and copies this checkout in as the `garrysmod` folder, with the `catwork` and `cwhl2rp` gamemodes and their content.

Before building, open `gamemodes/catwork/clockwork.cfg` and:

- replace the `owner_steamid` with your own Steam ID (`STEAM_0:X:XXXXXXXX`), which makes you a super admin;
- set `mysql_host` to `sqlite` unless you have a MySQL server. SQLite needs no setup. The shipped `localhost` points at the container itself, where no MySQL runs, so the server would keep retrying the connection.

```sh
# Clone the repository and build the image.
# This downloads the dedicated server (about 7 GB), so it will take a while.
git clone https://github.com/TeslaCloud/Catwork.git
cd Catwork
docker build -t catwork .

# Start the server.
docker run -it --name catwork -p 27015:27015/udp -p 27015:27015/tcp catwork
```

You are now looking at the srcds console. Press `Ctrl+P` followed by `Ctrl+Q` to leave it without stopping the server, and run `docker attach catwork` to get back to it.

```sh
# Stop the server.
docker stop catwork

# Start it again, keeping the database and all other data.
docker start -ai catwork
```

**The database and all other server data are stored inside the container.** Removing the container (`docker rm catwork`) deletes them, so use `docker start` rather than a second `docker run` to bring your server back up.

Anything you put after the image name replaces the default startup options:

```sh
docker run -it --name catwork -p 27015:27015/udp -p 27015:27015/tcp catwork \
  +gamemode catwork +schema cwhl2rp +map gm_flatgrass +maxplayers 32 -tickrate 30
```

Things to keep in mind:

- The whole checkout is copied into the image, `clockwork.cfg` included. Run `docker build` again after changing the code or the configuration, then create a new container.
- The binary modules are downloaded during the build and then cached. Add `--no-cache-filter modules` to `docker build` to fetch them again without downloading the server, and `--build-arg GMSV_FILE_VERSION=...` or `--build-arg MYSQLOO_VERSION=...` to pick a release.
- To use MySQL, point `mysql_host` in `clockwork.cfg` at a database server reachable from the container. On the Docker host, that is `host.docker.internal` on Docker Desktop and the host's LAN address on Linux, never `localhost`.

## Binary modules

The Docker image downloads these for you. Otherwise they are not shipped with this repository. Use the build that matches your server: `win32` / `linux` for 32-bit, `win64` / `linux64` for 64-bit.

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
