#!/usr/bin/python
import sys
if len(sys.argv) > 1:
    libdir=sys.argv[1]
    for path in sys.path:
        if path.endswith("site-packages") and (path.find('/' + libdir + '/') > 0 or path.find('\\' + libdir + '\\') > 0) and path.find("/local/") > 0:
            print(path)
            sys.exit(0)
    for path in sys.path:
        if path.endswith("site-packages") and (path.find('/' + libdir + '/') > 0 or path.find('\\' + libdir + '\\') > 0):
            print(path)
            sys.exit(0)
for path in sys.path:
    if path.endswith("site-packages"):
        print(path)
        sys.exit(0)
sys.exit(1)