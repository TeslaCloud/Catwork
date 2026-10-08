# The binary modules are fetched in their own stage, so that a new release of
# them does not invalidate the large server download below.
# Build with "--no-cache-filter modules" to pull in their newest versions.
FROM alpine/curl AS modules
ARG GMSV_FILE_VERSION=v1.3
ARG MYSQLOO_VERSION=9.7.6
WORKDIR /modules
RUN curl -fsSL -o gmsv_file_linux64.dll \
      "https://github.com/Meow/gmsv_file/releases/download/$GMSV_FILE_VERSION/gmsv_file_linux64.dll" \
 && curl -fsSL -o gmsv_mysqloo_linux64.dll \
      "https://github.com/FredyH/MySQLOO/releases/download/$MYSQLOO_VERSION/gmsv_mysqloo_linux64.dll"

FROM steamcmd/steamcmd:debian-trixie

RUN useradd --create-home --shell /bin/bash steam

USER steam
ENV USER=steam HOME=/home/steam
WORKDIR /home/steam/catwork_server

# Let steamcmd update itself first. Running the download right after the
# self-update tends to fail with "Missing configuration".
RUN steamcmd +quit

# The modules above are the 64-bit builds, so the server has to come from the x86-64 branch.
# The download is resumed on failure, which happens from time to time.
RUN attempt=0; until steamcmd +force_install_dir /home/steam/catwork_server +login anonymous +app_update 4020 -beta x86-64 validate +quit; do \
      attempt=$((attempt + 1)); [ "$attempt" -lt 5 ] || exit 1; sleep 10; \
    done

# Catwork needs gmsv_file to start at all and MySQLOO when the database is set to mysqloo.
COPY --from=modules --chown=steam:steam /modules garrysmod/lua/bin

# This checkout is laid out like the garrysmod folder: it ships the catwork and
# cwhl2rp gamemodes as well as the materials, models and resources they need.
COPY --chown=steam:steam . garrysmod

EXPOSE 27015/udp 27015/tcp

ENTRYPOINT ["./srcds_run_x64"]
CMD ["+gamemode", "catwork", "+schema", "cwhl2rp", "+map", "gm_construct", "+maxplayers", "64", "-tickrate", "30"]
