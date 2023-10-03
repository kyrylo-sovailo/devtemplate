#!/bin/sh
magick convert 16x16.png 24x24.png 32x32.png 48x48.png 64x64.png 128x128.png 256x256.png -colors 256 16-24-32-48-64-128-256.ico
magick convert 16x16.png 32x32.png           48x48.png                       256x256.png -colors 256 16-32-48-256.ico
magick convert 16x16.png 24x24.png 32x32.png 48x48.png 64x64.png                         -colors 256 16-24-32-48-64.ico