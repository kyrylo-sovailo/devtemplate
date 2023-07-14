#!/usr/bin/python
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/build") # Prefer local library over installed one
import devtemplate

if __name__ == "__main__":
    d = devtemplate.Devtemplate()
    correct = d.devtemplate() == 42
    print("Devtemplate is functioning correctly" if correct else "Devtemplate is malfunctioning")
    sys.exit(0 if correct else 1)