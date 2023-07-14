#!/usr/bin/python
import os, sys, unittest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/build")
import devtemplate

class Example(unittest.TestCase):
    def test_devtemplate(self):
        d = devtemplate.Devtemplate()
        self.assertEqual(d.devtemplate(), 0)

if __name__ == "__main__":
    unittest.main()