#!/bin/bash

docker build -t localhost:5000/mesos-do/mongo:latest .
docker push localhost:5000/mesos-do/mongo:latest