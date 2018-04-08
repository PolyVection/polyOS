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
import polywifi
from array import *


WSREGEX = re.compile(r"\s+")
DESTINATION_PATH = "/tmp/"
STATE_DIR = '/var/lib/edison_config_tools'
HOST_AP_MODE_FILE = "/.start-in-host-ap-mode"
CURR_PACKAGE_PATH = ""

class text_colors:
    CYAN = '\033[96m'
    MAGENTA = '\033[95m'
    BLUE  = '\033[94m'
    YELLOW = '\033[93m'
    GREEN = '\033[92m'
    RED = '\033[91m'
    END = '\033[0m'

def reset(stage):
    subprocess.call("clear", shell=True)
    print(text_colors.RED + "\n### " + stage + " ###\n" + text_colors.END)

def verified(selection):
    verify = input("Is " + text_colors.MAGENTA + selection + text_colors.END + " correct? " + text_colors.YELLOW + "[Y or N]" + text_colors.END + ": ")
    if verify == "Y" or verify == "y":
        return 1
    elif verify == "N" or verify == "n":
        return 0
    else:
        while 1:
            verify = input("Please enter either " + text_colors.YELLOW + "[Y or N]" + text_colors.END + ": ")
            if verify == "Y" or verify == "y":
                return 1
            elif verify == "N" or verify == "n":
                return 0

def printFTS():
    reset("PolyOS - First Time Setup")
    print("")
    print("This program will guide you through the progress of setting up \nthe network connection and other important things.")
    print("")
    print("STEP 1 - wireless setup")
    print("STEP 2 - audio output")
    print("")
    userinput = input("ENTER [y] TO CONTINUE OR [n] TO ABORT: ")
    if userinput == "Y" or userinput == "y":
        return 1
    elif userinput == "N" or userinput == "n":
            sys.exit(1)

def printFTSfinished():
    reset("PolyOS - First Time Setup")
    print("")
    userinput = input("First Time Setup completed! Hit [enter] to close.")
    sys.exit(1)




