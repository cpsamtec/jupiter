
# Jupiter

Containerized multi architecture and hardware supporting development environment. Can be run using docker-compose or deployed to [balena](https://www.balena.io/) devices. Features include

- [jupyter](https://jupyter.org/)
- [jupyter-lab](https://jupyterlab.readthedocs.io/en/stable/) with prebuilt extensions such as plotly, dash, matplotlib and more
- [code-server](https://github.com/cdr/code-server) VSCode in the browser
- ssh (supporting client key authentication)
- [minio-server](https://docs.min.io/docs/minio-quickstart-guide.html) a High Performance Object Storage released
- [minio-client](https://docs.min.io/docs/minio-client-quickstart-guide.html) (mc) provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff, find etc with s3 compatability
- user **dev**
- persistent directories /code, /lab, /home/dev
- i2c, gpio, spi, uart/serial configured to work with dev.
- nginx to expose jupyter, minio, device share, code server over the same port (default 80) with varying routes. Can use ngrok or balena then to make the development environment exposed publicly
- preinstalled languages include Rust, C/C++, Python 3 (w/ Poetry & Pipenv), Go, Nodejs (w/ nvm)

## Get Started

1. Get Repo
    1. git clone --recursive URL

    2. create a **.env** file in the root directory with the following contents

    ```bash
    JUPI_VIM_USER=0
    JUPI_DEFAULT_USER_PASSWORD=dev
    JUPI_OVERRIDE_USER_PASSWORD=dev
    JUPI_CREDENTIAL_VERSION=1
    JUPI_MYMINIO_ACCESS_KEY=minioadmin
    JUPI_MYMINIO_SECRET_KEY=minioadmin
    ```

2. Building

    Build project images using scripts/jupiter.sh. If you do not specify an architecture your current machines will be used.

    ```bash
    # x86_64
    bash scripts/jupiter.sh build amd64
    # arm64v8
    bash scripts/jupiter.sh build aarch64
    # arm32v7
    bash scripts/jupiter.sh build aarch32
    ```

3. Running (optional w/ docker-compose on current machine)

    1. make sure images are built following steps above (_Building_)
    2. get project environment variables from scripts/compose-env.sh

    ```bash
        source scripts/compose-env.sh
    ```

    3. run docker-compose up, down, exec ... commands as usual inside the repo directory.
    4. If you open a new terminal source **scripts/compose-env.sh**

4. Deploying to a device with balena

    1. go to balena console and create project jupiter-amd64 or jupiter-aarch64 or jupiter-aarch32 depending on hardware used
    2. run ```balena login```
    3. make sure images are built following steps above (_Building_)
    4. run jupiter.sh script

        ```bash
        # x86_64
        bash scripts/jupiter.sh deploy amd64
        # arm64v8
        bash scripts/jupiter.sh deploy aarch64
        # arm32v7
        bash scripts/jupiter.sh deploy aarch32
        ```

## Jupiter Environment

- User is **dev**
- Directories
  - /code persistent directory for coding projects
  - /lab persistent directory for jupyter lab notebook projects
  - /home/dev perisistent home directory for virtual envs and user configuration files
- SSH
  - port 28282
  - on local network only
  - password is _dev_ (configurable w/ JUPI_OVERRIDE_USER_PASSWORD)

## Connecting to Environment

- When running docker-compose on host address will be _localhost_ or _127.0.0.1_
- A balena device running the environment can use the first 7 digits of balena id followed by _.local_. example b123456.local. Make sure Bonjour/Zeroconf is installed on the machine you are conecting from
- A balena device IP can be found by going to the balena portal
- Many services of the environment can be accessed remotely at **https://[balena-device-id].balena-devices.com/[service]** when run from a balena device and public access is enabled. Services include
    - Code Server: In browser VSCode **/code**
    - Jupyter Lab: Python notebooks **/lab**
    - Minio: S3 local bucket server **/minio**

## SSH

- ssh for local network only development
- ssh dev@address -p 28282
- password is _dev_ (configurable w/ JUPI_OVERRIDE_USER_PASSWORD)
- port 28282 only

Jupiter also has support for using public client keys. Generate keys following tutorials online.

```bash
ssh-keygen -t rsa
# Place file in ~/.ssh/id_rsa_jupiter
# To copy public key to Jupiter environment
scp -P 28282 ~/.ssh/id_rsa_jupiter.pub dev@jupiter-host-address:~/.ssh/authorized_keys
# Alternativly to append new client
#cat ~/.ssh/id_rsa_jupiter.pub | ssh -p 28282 dev@host_addr "cat >> ~/.ssh/authorized_keys"
```

Example setting in ~/.ssh/config to connect simply with ```ssh jupiter```

```bash
Host jupiter
Hostname jupiter-host-addr
User dev
Port 28282
StrictHostKeyChecking no
IdentityFile ~/.ssh/id_rsa_jupiter
```

## Credentials

1. ssh onto device
2. bash /app/credentials.sh to get info on running services. tokens etc.

## WIFI/Network - Balena

By default a hotspot is created on wifi enabled devices. Look for WIFI network with name SDC-XXXXXXX where XXXXXXX is the 7 digit balena id. The password can be found under environment variables on the balena app dashboard. Look for SDC_WIFI_PASS. Other useful environment variables are as followed.

| Name              | Description                   | Default                                     |
| ----------------- | ----------------------------- | ------------------------------------------- |
| SDC_WIFI_TYPE     | enum: HOTSPOT CLIENT DISABLED | HOTSPOT                                     |
| SDC_WIFI_SSID     | WiFi SSID                     | SDC-${**BALENA_PREFIX**_DEVICE_UUID}        |
| SDC_WIFI_PASS     | WiFi passphrase               | samtec1!                                    |
| SDC_WIFI_IFACE    | WiFi hardware interface       | wlan0                                       |
| ETH_DISABLE       | Disable ethernet              | null                                        |
| ETH_TARGET_NAME   | Eth hardware interface        | null                                        |
| ETH_DHCP_TIMEOUT  | Timeout to get DHCP address   | 15                                          |
| ETH_LOCAL_TIMEOUT | Timeout to get autoip address | 30                                          |

## Development

### Jupyter Lab

Extensions have been installed and only need to be enabled. Do not install any further extensions as it will require a full rebuild and always causes problems. If JUPI_VIM_USER is set to 1 vim will be enabled on notebook cells.

From a browser goto

- On same local network
  - http://ip/lab
  - http://ip:8888
    (ip can be 7 digit balena device uuid.local or actual ip)
- Remote/Local running on a balena device only with internet access
  - https://[balena-device-id].balena-devices.com/lab

### Code Server

From a browser goto

- On same local network
  - http://ip/code
  - http://ip:8080
    (ip can be 7 digit balena device uuid.local or actual ip)
- Remote/Local running on a balena device only with internet access
  - https://[balena-device-id].balena-devices.com/code

some extensions have been installed by default.

### VSCode

Make sure to create new coding projects in /code directory of the Jupiter environment.

1. Add following to ~/.ssh/config on your machine

```bash
Host name-whatever  
HostName xxxxxxx.local
User dev
Port 28282
StrictHostKeyChecking no
```

2. Change Host to whatever you want to call environment running on device.
3. Change Hostname to 7 digit balena device uuid ending with .local or ip address of device.
4. Open VSCode on your computer
5. Make sure Remote - SSH extension installed
6. Ctrl/CMD+Shift+P REMOTE - SSH: Connect to host
7. Enter name-whatever (What you put after Host)
8. password is _dev_ (configurable w/ JUPI_OVERRIDE_USER_PASSWORD)

## Minio S3

A local s3 server is also running on the device with minio command line client. The server is called **myminio**. You can use the command line client **mc** to add/remove buckets and files just as though it were a directory with the only exception you cannot create directories. This is an object store. Examples

- list buckets: ```mc ls myminio```
- create bucket tests: ```mc mb myminio/tests```
- list file objects in bucket tests: ```mc ls myminio/tests```
- copy file to tests: ```mc cp mytest.txt myminio/tests```

Further client documentation can be found here
[Minio Client](https://docs.min.io/docs/minio-client-quickstart-guide.html)

A web client can be found using a web browser going to

- On same local network
  - http://ip/minio
  - http://ip:9000
    (ip can be 7 digit balena device uuid.local or actual ip)
- Remote/Local running on a balena device only with internet access
  - https://[balena-device-id].balena-devices.com/myminio

Credentials can be found in environment keys

- JUPI_MYMINIO_ACCESS_KEY: default minioadmin
- JUPI_MYMINIO_SECRET_KEY: default minioadmin

If the following credentials are set the minio client can be used on s3 (example mc ls s3/)

- JUPI_AWS_ACCESS_KEY_ID
- JUPI_AWS_SECRET_ACCESS_KEY

## Software Tools

The following tools have been installed and are ready to use.

- NVM
- Pipenv
- Poetry
- C/C++
- Rust
- GO

## Docker

On balena devices **/var/run/balena.sock** is exposed. The Jupiter environment also includes docker-compose. This means you can build and run containers from the Jupiter environment. The environment variable DOCKER_HOST will be preconfigured to use this **/var/run/balena.sock**

When running directly on your machine with docker-compose you can expose the docker.sock to the environment by running

```bash
docker-compose  -f docker-compose.yml -f docker-compose-local-sock.yml up
```

The overriding dockerfile mounts the appropriate docker.sock volume. You can create your own overriding docker-compose files to change ports and passwords.

## Environment Variables

For service notebook

- Enable/Disable VIM mode and extensions in Jupyter Lab and Code Server. 0 - Disabled (default), 1 - Enabled
    - JUPI_VIM_USER
- Enable minio client to access AWS S3. (ex. mc ls s3/)
    - JUPI_AWS_ACCESS_KEY_ID
    - JUPI_AWS_SECRET_ACCESS_KEY
- If credentials are changed (s3 or myminio) increase this value so the new ones are configured to be used in the environment. Default 1
    - JUPI_CREDENTIAL_VERSION
- Change the build time user password for dev
    - JUPI_DEFAULT_USER_PASSWORD
- Change the runtime user password for dev. Will be different than what is in generated image
    - JUPI_OVERRIDE_USER_PASSWORD
- Change the myminio default passwords. Make sure greater than 8 characters
    - JUPI_MYMINIO_ACCESS_KEY
    - JUPI_MYMINIO_SECRET_KEY
