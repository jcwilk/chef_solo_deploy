#!/bin/sh

wget http://www.steampowered.com/download/hldsupdatetool.bin &&
chmod +x hldsupdatetool.bin &&
echo "yes" | ./hldsupdatetool.bin &&
chmod +x steam &&
(./steam || true) #we don't care what this returns... it's for updating itself and it throws bad return codes like crazy