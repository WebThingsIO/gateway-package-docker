This repository creates a docker image which hosts the OpenWRT toolchain
used to build addons for the gateway.

# Build the docker image

Run the `build-toolchain.sh` script to build the docker image containing the
toolchain.

# Push the toolchain.

Currently the toolchain is hosted under dhylands account. If you want to change
this, you'll need to update the owrt script.

To push the toolchain once its built use the command:
```
docker push dhylands/openwrt-toolchain-rpi:toolchain-rpi
```

# Run commands using the toolchain.

The docker image isn't intended to run directly. Instead you should do:
```
docker run dhylands/openwrt-toolchain-rpi:toolchain-rpi > owrt
chmod +x owrt
```
You can then place owrt someplace in your PATH and use it to run commands:
```
owrt bash
```
will give you a bash shell inside the docker container. The Docker image will
have a /home/build/.owrt file which will contain several variables to locate
the toolchain and add it to the PATH.
