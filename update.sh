#!/bin/bash

git submodule update --recursive --init
git submodule foreach git pull
