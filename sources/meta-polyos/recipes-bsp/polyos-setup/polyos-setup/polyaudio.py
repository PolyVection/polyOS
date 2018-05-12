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
# aplay -l | awk -F \: '/,/{print $2}' | awk '{print $1}' | uniq

import os
import sys
from sys import stdout
import time
import termios
import fcntl
import subprocess
import polyterminal

def selectSPDIF():
    f = open("/mnt/data/settings/audio/alsa/asound.conf", 'w')
    f.write("ctl.!default {\n")
    f.write("type hw\n")
    f.write("card pcm5121\n")
    f.write("}\n")
    f.write("pcm.!default {\n")
    f.write("type hw\n")
    f.write("card imxspdif\n")
    f.write("}\n")
    f.close()

def selectLINE():
    f = open("/mnt/data/settings/audio/alsa/asound.conf", 'w')
    f.write("ctl.!default {\n")
    f.write("type hw\n")
    f.write("card pcm5121\n")
    f.write("}\n")
    f.write("pcm.!default {\n")
    f.write("type hw\n")
    f.write("card pcm5121\n")
    f.write("}\n")
    f.close()

def selectAMP1():
    f = open("/mnt/data/settings/audio/alsa/asound.conf", 'w')
    f.write("ctl.!default {\n")
    f.write("type hw\n")
    f.write("card is31ap2121\n")
    f.write("}\n")
    f.write("pcm.!default {\n")
    f.write("type hw\n")
    f.write("card is31ap2121\n")
    f.write("}\n")
    f.close()

def chooseFTS():
    polyterminal.reset("PolyOS - Audio Setup")
    print("")
    print("Please select the audio output:")
    print("-----------------------------------------")
    print("")
    print("0 -\t TOSLINK \t(ZERO)")
    print("1 -\t ANALOG  \t(ZERO)")
    print("2 -\t AMPLIFIER\t(AMP1)")
    print("3 -\t DAC\t\t(M1-0006)")
    print("4 -\t SPDIF\t\t(M1-0006 + M1-0007)")

    print("")
    user = input("Enter either 0, 1, 2, 3 or 4 to configure audio output: ")
    if "0" in user:
        selectSPDIF()
    elif "1" in user:
        selectLINE()
    elif "2" in user:
        selectAMP1()
    elif "3" in user:
        selectLINE()
    elif "4" in user:
        selectSPDIF()
    else:
        print("SOMETHING WENT WRONG - TRY AGAIN: ", user)
        time.sleep(1)
        chooseFTS()
