#!/bin/sh
rsync -r -u --del --progress -6 public/ cjs@chrissnell.com:/web/sites/chrissnell.com/
