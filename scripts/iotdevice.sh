#!/bin/bash

az iot hub device-identity create -n iottechiot -d Simulator
az iot hub module-identity create --device-id Simulator --module-id DUAgent --hub-name iottechiot
az iot hub module-twin update -n iottechiot -d Simulator -m DUAgent --tags '{"ADUGroup": "DU-simulator-tutorial"}'
