#!/usr/bin/python
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/build")            #Search in build directory
sys.path.insert(1, "/usr/local/lib/python" + '.'.join(sys.version.split('.')[:2]) + "/site-packages") #Search in /usr/local/lib
import devtemplate

if __name__ == "__main__":
    d = devtemplate.Devtemplate()
    correct = d.calculate() == 42
    print(devtemplate.Devtemplate.version + (" is functioning correctly" if correct else " is malfunctioning"))
    sys.exit(0 if correct else 1)