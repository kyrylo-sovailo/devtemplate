#!/usr/bin/python
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/build")
import devtemplate

if __name__ == "__main__":
    d = devtemplate.Devtemplate()
    r = d.devtemplate()
    sys.exit(r)