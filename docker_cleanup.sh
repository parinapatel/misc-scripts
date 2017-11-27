#!/bin/bash
docker -H 0.0.0.0:2375 rmi $(docker images -q)
