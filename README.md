# Jupiter

<img src="sds/img.png" alt="jupiter" width="200"  style="background-color:black"/>

Development environment


## Get Repo

git clone --recursive URL

## Running

- **Balena**. This project has been prebuilt and uploaded to Balnea projects jupyter (arm64v8) and jupyter-x86 (amd64)

- **Docker Compose** (build and run locally)
  1. source scripts/env.sh
  2. bash scripts/jupiter.sh build (build images)
  3. run docker-compose up, down ... commands as usual inside the repo directory

## Environment

- user is _dev_
- directories
  - /code persistent directory for coding applications
  - /lab persistent directory for jupyter lab
  - /home/dev perisistent home directory for virtual envs and user configuration files
- ssh
  - port 28282
  - on local network only
  - password is _dev_ (will be configurable in future)

## Connecting to Environment

- When running docker-compose on host address will be localhost or 127.0.0.1
- On a balena device can use the first 7 digits of balena id followed by .local. example b123456.local. Make sure Bonjour/Zeroconf is installed on the machine you are conecting from
- A balena device IP can be found by going to the balena portal
- Many services of the device can be accessed remotely at **https://[balena-device-id].balena-devices.com/[service]** when run from a balena device and public access is enabled. Services include
    - Code Server: In browser VSCode
    - Jupyter Lab: Python notebooks
    - Minio: S3 local bucket server


## Local SSH

- ssh for local network only development
- ssh dev@address -p 28282
- password is _dev_ (will be configurable in future)
- port 28282 only

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

## Coding

### Jupyter Lab

Extensions have been installed and only need to be enabled. Do not install any further extensions as it will require a full rebuild and always causes problems. If VIM_USER is set to 1 vim will be enabled on the notebook.

From browser goto

- On same local network
  - http://ip/lab
  - http://ip:8888
    (ip can be 7 digit balena device uuid.local or actual ip)
- running on a balena device only
  - https://[balena-device-id].balena-devices.com/lab

### code server

From browser goto

- On same local network
  - http://ip/code
  - http://ip:8080
    (ip can be 7 digit balena device uuid.local or actual ip)
- Running on a balena device only
  - https://[balena-device-id].balena-devices.com/code

some extensions have been installed by default.

### VSCode

Make sure to create new coding projects in /code.

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

## Minio S3
