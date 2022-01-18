#!/usr/bin/python3

# Command line arguments:  tar.gz files

import sys
import tarfile
import re
import hashlib
import os
import shutil

failregex  = re.compile('.*(failures.*).trace')
outputdir = 'bugs'

stackframeregex = re.compile('\s*at.*\(.*.java.*\)')
maxdepth=3

bugs = {}

shutil.rmtree(outputdir,True)

for fname in sys.argv[1:]:
    print(fname)
    with tarfile.open(fname) as tgz:
        for tgzfile in tgz.getmembers():
            # Is this file in the archive a fail?
            if not failregex.match(tgzfile.name):
                continue
            print(tgzfile.name)
            with tgz.extractfile(tgzfile.name) as f:
                # hash the contents of the fail trace
                h = hashlib.md5()
                depth=0
                for line in f.readlines():
                    # skip all the lines that don't have a stack frame
                    if not stackframeregex.match(line.decode()):
                        continue
                    h.update(line)
                    depth += 1
                    # only look at the top-most maxdepth stack frames
                    if depth > maxdepth:
                        break
                md5 = h.hexdigest()
                cwd = os.path.join(outputdir,md5)

                # use hash to reason about the uniqueness of the fail
                if md5 in bugs:
                    b = bugs[md5]
                else:
                    b = []
                    bugs[md5] = b
                    os.makedirs(cwd)

                # extract stacktrace to the correct dir
                tgz.extract(tgzfile, cwd)
                # extract offending input file to the correct dir
                tgz.extract(re.sub(r'\.trace$', '.input', tgzfile.name), cwd)
                # register failure in our index
                b.append(tgzfile.name)

print("Found {} unique bugs".format(len(bugs)))

i=0
for b,fs in bugs.items():
    i += 1
    print("Bug {} was found {} times".format(i,len(fs)))
    # rename dir from md5 to sequential id
    fro  = os.path.join(outputdir,b)
    to   = os.path.join(outputdir,str(i))
    shutil.move(fro,to)
