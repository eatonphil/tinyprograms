#!/usr/bin/env python3

import os
import subprocess
import sys
from uuid import UUID

for r in range(1_000):
    out = subprocess.check_output(sys.argv[1], shell=True).decode().strip()
    # If not a valid UUID, this will throw
    print(out)
    got = UUID(out, version=4).hex
    if got != out.replace('-', ''):
        raise Exception('Got "{}", wanted "{}"'.format(got, out.replace('-', '')))
