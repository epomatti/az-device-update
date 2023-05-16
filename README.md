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

Upload the template config:

```sh
scp ./config/du-config-template.json "simulator@<PUBLIC-IP>"
```

```sh
sudo nano /etc/adu/du-config.json

# Add the 
az iot hub module-identity connection-string show --device-id Simulator --module-id DUAgent --hub-name iottechiot
```

## Sources

- [IoT Hub Modules Twins](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-module-twins)
- [IoT Hub Device Twins](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins)
