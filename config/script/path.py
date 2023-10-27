#!/usr/bin/python3
import sys, site
s = site.getsitepackages()

for i in range(len(s) - 1, 0, -1):
    if s[i].startswith("/usr/lib"):
        print(s[i][len("/usr/"):])
        sys.exit(0)

for i in range(len(s) - 1, 0, -1):
    if s[i].startswith("/usr/"):
        print(s[i][len("/usr/"):])
        sys.exit(0)

print(s[-1])
sys.exit(0)