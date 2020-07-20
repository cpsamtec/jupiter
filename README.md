
# Jupiter

Development environment

![Image](sds/img.png)

## Get Repo

git clone --recursive URL

## Environment

* user is _dev_
* directories
  * /code persistent directory for coding applications
  * /lab persistent directory for jupyter lab
  * /home/dev perisistent home directory for virtual envs and user configuration files
* ssh
  * port 28282
  * on local network only
  * password dev (will change in future)

## Running

* **Balena**. This project has been prebuilt and uploaded to Balnea projects jupyter (arm64v8) and jupyter-x86 (amd64)

* **Docker Compose** (build and run locally)
    1. source scripts/env.sh
    2. bash scripts/jupiter.sh build (build images)
    3. run docker-compose up, down ... commands as usual inside the repo directory

## Local SSH

* ssh for local only development. port 28282.  
* **ssh dev@address -p 28282**

## Credentials

1. ssh onto device
2. bash /app/credentials.sh to get info on running services. tokens etc.

## Coding

### Jupyter Lab

Extensions have been installed and only need to be enabled. Do not install any further extensions as it will require a full rebuild and always causes problems. If VIM_USER is set to 1 vim will be enabled on the notebook.

From browser goto

* On same local network
  * http://ip/lab
  * http://ip:8888
  (ip can be 7 digit balena device uuid.local or actual ip)
* running on a balena device only
  * https://[balena-device-id].balena-devices.com/lab

### code server

From browser goto

* On same local network
  * http://ip/code
  * http://ip:8080
    (ip can be 7 digit balena device uuid.local or actual ip)
* Running on a balena device only
  * https://[balena-device-id].balena-devices.com/code

some extensions have been installed by default. 

### VSCode

Make sure to create new coding projects in /code.

1. Add following to ~/.ssh/config on your machine

_Host name-whatever_   
_HostName xxxxxxx.local_   
_User dev_  
_Port 28282_  
_StrictHostKeyChecking no_  

2. Change Host to whatever you want to call environment running on device.
3. Change Hostname to 7 digit balena device uuid ending with .local or ip address of device.
4. Open VSCode on your computer
5. Make sure Remote - SSH extension installed
6. Ctrl/CMD+Shift+P REMOTE - SSH: Connect to host 
7. Enter name-whatever (What you put after Host)

## Minio S3
