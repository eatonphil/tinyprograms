#!/usr/bin/env python3

import os
import subprocess
import sys

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


def run_test_file(project, test):
    with open(project + "/_tests/" + test + ".stdout") as e:
        expected = e.read().encode()
        
    run_steps = program['run']
    run_steps = run_steps if isinstance(run_steps, list) else [run_steps]

    for run_step in run_steps:
        try:
            out = subprocess.check_output(program['run'].format(PROGRAM="../_tests/" + test), shell=True, cwd=language)
        except Exception as e:
            print(e)
            out = ""
        if out != expected:
            print("[{}, {}]: Expected '{}', got '{}'.".format(project.split('/')[1], language.split('/')[-1], expected, out))
            global failed
            failed = True


language_filter = None
for i, arg in enumerate(sys.argv):
    if arg in ["--language", "-l"]:
        language_filter = sys.argv[i+1]
    
for project in subdirs(REPO_ROOT):
    if project in NON_PROJECT_DIRS:
        continue

    for language in subdirs(REPO_ROOT + project):
        l_name = language.split('/')[-1]
        if language_filter is not None and l_name != language_filter:
            continue

        if "_tests" in language:
            continue

        if not os.path.exists(language + "/program.yaml"):
            continue

        with open(language + "/program.yaml") as f:
            program = yaml.load(f, Loader=yaml.Loader)

            for step in program['prepare']:
                res = subprocess.run(step, shell=True, cwd=language, capture_output=True)
                if res.returncode != 0:
                    print(res.stdout.decode())
                    print(res.stderr.decode())

            if os.path.exists(project + "/_tests"):
                for test in os.listdir(project + "/_tests"):
                    if test.endswith('.stdout'):
                        continue

                    print("Running {} for {}".format(test, l_name))

                    run_test_file(project, test)
            elif os.path.exists(project + "/test_runner.py"):
                print("Running {}/test_runner.py for {}".format(project, l_name))
                res = subprocess.run(os.path.abspath(project) + "/test_runner.py " + program["run"], shell=True, cwd=language, capture_output=True)
                if res.returncode != 0:
                    print(res.stdout.decode())
                    print(res.stderr.decode())
                    failed = True


if failed:
    print("Tests failed.")
    exit(1)
else:
    print("All tests succeeded.")
