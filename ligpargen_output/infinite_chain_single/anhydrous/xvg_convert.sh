#!/bin/bash

filename=$1

grace -nxy "$filename.xvg" -hdevice PNG -hardcopy -printfile "$filename.png"
