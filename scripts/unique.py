#!/usr/bin/python3

# Command line arguments:  Directory containing CONFETTI result tarballs

import sys
import tarfile
import re
import hashlib
import os
import shutil

failregex  = re.compile('.*(failures.*).trace')
outputdir = 'bugs'

projects = ["ant-knarr-z3",
            "ant-jqf",
            "ant-knarr-z3-no-global-hint",
            "bcelgen-knarr-z3",
            "bcelgen-jqf",
            "bcelgen-knarr-z3-no-global-hint",
            "closure-knarr-z3"
            "closure-jqf",
            "closure-knarr-z3-no-global-hint",
            "maven-knarr-z3",
            "maven-jqf",
            "maven-knarr-z3-no-global-hint",
            "rhino-knarr-z3",
            "rhino-jqf",
            "rhino-knarr-z3-no-global-hint"]


stackframeregex = re.compile('\s*at.*\(.*.java.*\)')
maxdepth=3

bugs = {}

shutil.rmtree(outputdir,True)

fnames =[]
for project in projects:
    for i in range(1,21):
        fnames.append(os.path.join(sys.argv[1], "%s-%d.tgz" % (project, i)))



for fname in fnames:
    print(fname)
    with tarfile.open(fname) as tgz:
        for project in projects:
            for tgzfile in tgz.getmembers():
                # Is this file in the archive a fail?
                if not failregex.match(tgzfile.name):
                    continue
                if not project in tgzfile.name:
                    continue
                elif project in tgzfile.name:
                    if "-no-global-hint" in tgzfile.name and "-no-global-hint" not in project:
                        continue
                    if "-no-global-hint" in project and "-no-global-hint" not in tgzfile.name:
                        continue

                if project not in bugs:
                    bugs[project] = {}

                #print(tgzfile.name)
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
                    cwd = os.path.join(outputdir,project,md5,"")

                    # use hash to reason about the uniqueness of the fail
                    if md5 in bugs[project]:
                        b = bugs[project][md5]
                    else:
                        b = []
                        bugs[project][md5] = b
                        if not os.path.exists(cwd):
                            os.makedirs(cwd)

                    # extract stacktrace to the correct dir
                    tgz.extract(tgzfile, cwd)
                    # extract offending input file to the correct dir
                    tgz.extract(re.sub(r'\.trace$', '.input', tgzfile.name), cwd)
                    # register failure in our index
                    b.append(tgzfile.name)
            


# Print out information about bugs for each project
for project in projects:
    i=0
    print("Found %d unique bugs for project %s" % (len(bugs[project]), project))
    for b,fs in bugs[project].items():
        i += 1
        cwd = os.path.join(outputdir,project,b)
        #print(cwd)

        print("Bug {} was found {} times".format(b, len(next(os.walk(cwd))[1])))
    print("\n\n")