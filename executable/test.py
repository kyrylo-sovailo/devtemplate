#!/usr/bin/python
import os, sys, unittest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/build")          # Search in build directory
sys.path.insert(1, "/usr/local/lib/python" + '.'.join(sys.version.split('.')[:2]) + "site-packages")# Search in /usr/local/lib
import devtemplate

class Example(unittest.TestCase):
    def test_devtemplate(self):
        d = devtemplate.Devtemplate()
        self.assertEqual(d.devtemplate(), 42)

if __name__ == "__main__":
    unittest.main()