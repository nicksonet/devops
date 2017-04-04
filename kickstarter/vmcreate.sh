#!/bin/bash

# 


echo "Hello, "$USER"! Please location ks script to /path/to/ks.cfg"

echo -n "Enter name virtual machine and press [ENTER]: "
read name
echo

echo -n "Enter location ISO file for  virtual machine "$name" and press [ENTER]:
INFO: default location ISO for Centos 7 /path/to/CentOS-7-x86_64-Minimal-1611.iso "
read iso
echo


echo -n "Enter avalible memorry (megabyte) for virtual machine "$name" and press [ENTER]: "
read memorry
echo

echo -n "Enter disk size (gigabyte) for virtual machine "$name" and press [ENTER]: "
read disc
echo

echo -n "Enter availible vcpus for virtual machine "$name" and press [ENTER]: "
read cpu
echo


sudo virt-install --name "$name" --location "$iso" --initrd-inject /path/to/ks.cfg --extra-args ks=file:/ks.cfg --memory="$memorry" --vcpus="$cpu" --disk size="$disc"
