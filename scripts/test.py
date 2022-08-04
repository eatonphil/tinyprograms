#!/usr/bin/env python3

import os
import subprocess

import yaml

REPO_ROOT = "./"
NON_PROJECT_DIRS = [REPO_ROOT + r for r in [
    "site",
    "scripts",
]]

failed = False

def subdirs(path):
    for f in os.scandir(path):
        if f.is_dir():
            yield f.path

for project in subdirs(REPO_ROOT):
    if project in NON_PROJECT_DIRS:
        continue

    for language in subdirs(REPO_ROOT + project):
        if "_tests" in language:
            continue

        if not os.path.exists(language + "/program.yaml"):
            continue

        with open(language + "/program.yaml") as f:
            program = yaml.load(f, Loader=yaml.Loader)

            for test in os.listdir(project + "/_tests"):
                if test.endswith('.stdout'):
                    continue

                for step in program['prepare']:
                    subprocess.run(step, shell=True, cwd=language, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                out = subprocess.check_output(program['run'].format(PROGRAM="../_tests/" + test), shell=True, cwd=language)
                with open(project + "/_tests/" + test + ".stdout") as e:
                    expected = e.read().encode()
                if out != expected:
                    print("[{}, {}]: Expected '{}', got '{}'.".format(project.split('/')[1], language.split('/')[-1], expected, out))
                    failed = True


if failed:
    print("Tests failed.")
    os.exit(1)
else:
    print("All tests succeeded.")
