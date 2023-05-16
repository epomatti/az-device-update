# Azure 

Azure Device Update demonstration using the standard [DU Simulator handler](https://learn.microsoft.com/en-us/azure/iot-hub-device-update/device-update-simulator).

```sh
terraform init
terraform apply -auto-approve
```

Once the IoT Hub is provisioned, create a device:

```sh
# Create the device identity
az iot hub device-identity create -n iottechiot -d Simulator

# Create the module identity
az iot hub module-identity create --device-id Simulator --module-id DUAgent --hub-name iottechiot
```

Add this tag to the module-twin:

```sh
az iot hub module-twin update -n iottechiot -d Simulator -m DUAgent --tags '{"ADUGroup": "DU-simulator-tutorial"}'
```

How verify that the `cloud-init` config is done.

```sh
ssh simulator@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status
```

If the status is `status: done` then restart the VM:

> This is required for the DU agent but also to apply any kernel updates to the VM

```sh
az vm restart -g rgtechiot -n vmtechiotsimulator
```

Connect again to the VM after restarting it.

Upload the pre-filled template config:

```sh
scp ./config/du-config-template.json simulator@<PUBLIC-IP>:
```

Edit the connection string:

```sh
sudo nano du-config-template.json

# Update the connection string
az iot hub module-identity connection-string show --device-id Simulator --module-id DUAgent --hub-name iottechiot
```

Update the `du-config.json` file:

```sh
sudo cp du-config-template.json /etc/adu/du-config.json
```

Set up the agent to run as a simulator:

```sh
sudo /usr/bin/AducIotAgent --extension-type updateContentHandler --extension-id 'microsoft/swupdate:1' --register-extension /var/lib/adu/extensions/sources/libmicrosoft_simulator_1.so
```

## Sources

- [IoT Hub Modules Twins](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-module-twins)
- [IoT Hub Device Twins](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins)
