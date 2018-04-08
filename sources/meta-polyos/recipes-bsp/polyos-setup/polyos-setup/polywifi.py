#!/usr/bin/python3

# Copyright (c) 2017, PolyVection UG.
#
# Based on configure-edison, Intel Corporation.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU Lesser General Public License,
# version 2.1, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
# more details.
#

import os
import sys
from sys import stdout
import time
import termios
import fcntl
import subprocess
import signal
#import urllib2
import hashlib
import argparse
import json
import re
import polyterminal
import dbus
import shutil


def scanForNetworks():
    polyterminal.reset("PolyOS - Wireless Connectivity")
    stdout.write("Starting scan\r")
    stdout.flush()
    subprocess.check_output(["systemctl", "enable", "connman"], stderr=subprocess.STDOUT)
    subprocess.check_output(["systemctl", "start", "connman"], stderr=subprocess.STDOUT)
    subprocess.check_output(["connmanctl", "enable", "wifi"], stderr=subprocess.STDOUT)
    r = range(4,0,-1)
    for i in r:
        stdout.write("Scanning for networks: %s seconds left \r" % i)
        stdout.flush()
        if i == 4:
            subprocess.check_output(["connmanctl", "scan", "wifi"], stderr=subprocess.STDOUT)
        time.sleep(1)

    wifi_names = []
    wifi_ids = []
    wifi_signals = []

    bus = dbus.SystemBus()

    manager = dbus.Interface(bus.get_object("net.connman", "/"),
                         "net.connman.Manager")

    for path, properties in manager.GetServices():
        service = dbus.Interface(bus.get_object("net.connman", path),
                             "net.connman.Service")
        identifier = path[path.rfind("/") + 1:]
        id = str("%s" % (identifier))
        wifi_ids.append(id)
        
        for key in properties.keys():
            if key in ["Strength"]:
                wifi_signals.append(int(properties[key]))
            elif key in ["Name"]:
                wifi_names.append(str("%s" % (properties[key])))
            else:
                val = properties[key]
                    

    wifi_info = [[],[],[]]
    wifi_info[0] = wifi_names
    wifi_info[1] = wifi_ids
    wifi_info[2] = wifi_signals

    return(wifi_info)


def selectNetwork(wifi_info):
    polyterminal.reset("PolyOS - Wireless Connectivity")
    i = 2
    print("0 :\t  Rescan for networks")
    print("1 :\t  Skip WiFi Setup")
    print("2 :\t  Reserved for future use")
    print("-------------------------------------------------------------")
    for ssid in wifi_info[0]:
        i = i + 1
        print(i, ":\t", polyterminal.text_colors.BLUE, ssid, polyterminal.text_colors.END, "(Signal:", wifi_info[2][i-3], "%)")
    
    print("")
    choice = -1
    while 1:
        try:
            if i == 2:
                choice = int(input("\nEnter 0 to rescan for networks.\nEnter 1 to exit: "))
            elif i == 3:
                choice = int(input("\nEnter 0 to rescan for networks.\nEnter 1 to exit.\nEnter 3 to choose %s: " % wifi_info[0][0]))
            else:
                choice = int(input("\nEnter 0 to rescan for networks.\nEnter 1 to exit.\nEnter a number between 3 to %s to choose one of the listed network SSIDs: " % i))
        except TypeError:
            choice = -1
        except ValueError:
            choice = -1

        if choice == 0:
            break
        elif choice == 1:
            sys.exit(0)
        elif choice == 2:
            break
        elif choice > 2 and choice <= i and polyterminal.verified(wifi_info[0][choice-3]):
            wifi_name = wifi_info[0][choice-3]
            wifi_password = getPassword()
            wifi_id = wifi_info[1][choice-3]
            wifi_conf = []
            wifi_conf.append(wifi_id)
            wifi_conf.append(wifi_name)
            wifi_conf.append(wifi_password)
            writeConf(wifi_conf)
            break

    return choice

def getPassword():
    return input("Now enter your password: ")

def writeConf(wifi_conf):
    
    wifi_directory = "/var/lib/connman/" + wifi_conf[0]
    
    if not os.path.exists(wifi_directory):
        os.makedirs(wifi_directory)
    else:
        shutil.rmtree(wifi_directory)
        os.makedirs(wifi_directory)

    f = open(wifi_directory+"/settings", 'w')
    f.write("["+wifi_conf[0]+"]\n")
    f.write("Name="+wifi_conf[1]+"\n")
    f.write("Favorite=true\n")
    f.write("AutoConnect=true\n")
    f.write("Passphrase="+wifi_conf[2]+"\n")
    f.close()

    subprocess.check_output(["systemctl", "restart", "connman"], stderr=subprocess.STDOUT)
    checkNetwork()

def checkNetwork():
    polyterminal.reset("PolyOS - Wireless Connectivity")
    i = 60
    print("")
    while 1:
        waiting = "Connecting to your WiFi: %s seconds left         \r" % i
        stdout.write(waiting)
        stdout.flush()
        time.sleep(1)
        address = os.popen("ifconfig | grep -A1 'wlan0' | grep 'inet'| awk -F' ' '{ print $2 }' | awk -F':' '{ print $2 }'").read().rstrip()
        if not address == "":
            polyterminal.reset("PolyOS - Wireless Connectivity")
            print("")
            print("CONNECTED! IP address: "+address)
            break
        if i == 0:
            print("Not connected. Something went wrong. Please try again.")
            break
        i = i-1

    print("")
    user = input("Hit [enter] to continue")

def connectFTS():
    while 1:
        choice = selectNetwork(scanForNetworks())
        if choice == 0:
            print ("Scanning again.")
        if choice == 1:
            return 0
        if choice == 2:
            return 0
        if choice > 2:
            break



