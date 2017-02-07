#!/bin/bash
sudo sed -i '$s/$/ --insecure-registry=registry.marathon.mesos:5000/' /etc/systemd/system/docker.service.d/execstart.conf
sudo systemctl daemon-reload
sudo systemctl restart docker