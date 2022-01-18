#!/usr/bin/env python2

import csv
import sys
import numpy as np

import tarfile

import math

from difflib import SequenceMatcher
from re import sub

from os.path import split

data = {}
names = None

datafiles = []

def longestCommonPrefix(strs):
    longest_pre = ""
    if not strs: return longest_pre
    shortest_str = min(strs, key=len)
    for i in range(len(shortest_str)):
        if all([x.startswith(shortest_str[:i+1]) for x in strs]):
            longest_pre = shortest_str[:i+1]
        else:
            break
    return longest_pre

# Get all data files from tar.gz
with tarfile.open(sys.argv[1], "r:gz") as tar:
    for f in tar.getnames():
        if f.endswith('plot_data'):
            datafiles.append(f)

# Get the name for the output file
output=sub(r'[^a-zA-Z0-9]$','', longestCommonPrefix(datafiles)) + '.csv'

# Initialize all columns
with tarfile.open(sys.argv[1], "r:gz") as tar:
    csvfile = tar.extractfile(datafiles[0])
    reader = csv.DictReader(csvfile, delimiter=',')
    names = reader.fieldnames
    for name in reader.fieldnames:
        data[name] = {}

# Collect all data from all files
fn = 0
times = []
with tarfile.open(sys.argv[1], "r:gz") as tar:
    for f in datafiles:
        print('Processing ' + f)
        csvfile = tar.extractfile(f)
        reader = csv.DictReader(csvfile, delimiter=',')
        t0 = None
        for line in reader:
            t = int(line['# unix_time'])
            if t0 is None:
                t0 = t
            t = t - t0
            times.append(t)
            for name in data:
                if name == '# unix_time':
                    continue
                if t not in data[name]:
                    data[name][t] = [None] * len(datafiles)
                data[name][t][fn] = float(line[name].replace('%',''))
        csvfile=None
        fn += 1

# Dedup and sort times
times = sorted(set(times))

# Carry data over time
means = {}
for col in data:
    means[col] = {}
    if col == '# unix_time':
        continue
    current = [None] * len(datafiles)
    for t in sorted(times):
        for i in range(0,len(current)):
            if t in data[col] and data[col][t][i] is not None:
                current[i] = data[col][t][i]
        # Average data
        means[col][t] = np.mean(current)

with open(output, 'w') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=names)
    writer.writeheader()
    row = {}
    for t in times:
        row['# unix_time'] = t
        for d in means:
            if d == '# unix_time':
                continue
            row[d] = means[d][t]
        writer.writerow(row)

print('Written ' + output)
