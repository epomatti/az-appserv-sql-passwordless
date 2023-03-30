#!/bin/bash

rm -f ./bin/webapi.zip
dotnet publish --configuration Release --output ./bin/publish
cd ./bin/publish
zip -r -q ../webapi.zip .
