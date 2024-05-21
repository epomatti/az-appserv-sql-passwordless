#!/bin/bash

repository=icecream
local_image="icecream-api-local"
acr_image="$acr.azurecr.io/$repository:latest"

localTag=icecream-api

az acr login --name $acr
docker build -t $local_image .
docker tag $local_image $acr_image
docker push $acr_image
