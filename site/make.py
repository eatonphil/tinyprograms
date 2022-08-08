#!/usr/bin/env python3

import os
import subprocess

import yaml
from jinja2 import Template

REPO_ROOT = "./"
NON_PROJECT_DIRS = [REPO_ROOT + r for r in [
    "site",
    "scripts",
]]

OUT_ROOT = REPO_ROOT + "build"
shutil.rmtree(OUT_ROOT)
os.makedirs(OUT_ROOT)

def subdirs(path):
    for f in os.scandir(path):
        if f.is_dir():
            yield f.path

with open(REPO_ROOT + 'site/template.html') as file_:
    template = Template(file_.read())

PROJECTS = {}

for project in subdirs(REPO_ROOT):
    if project in NON_PROJECT_DIRS:
        continue

    p_name = project.split('/')[-1]
    PROJECTS[p_name] = {
        "implementations": [],
    }

    for language in subdirs(REPO_ROOT + project):
        if "_tests" in language:
            continue

        if not os.path.exists(language + "/program.yaml"):
            continue

        l_name = language.split('/')[-1]
        PROJECTS[p_name]["implementations"].append(l_name)

for project_name, project in PROJECTS.items:
    if not os.exists(OUT_ROOT + "/" + p_name):
        os.makedirs(OUT_ROOT + "/" + p_name)

    for language in project["implementations"]:
        program = open(language).read()

        with open(language + "/program.yaml") as f:
            program_desc = yaml.load(f, Loader=yaml.Loader)

        with open(OUT_ROOT + "/" + p_name + "/" + l_name, 'w') as f:
            f.write(template.render(**program_desc, program=program, project_name=project_name, project=project, language=language))

with open(REPO_ROOT + "site/index.html") as f:
    template = Template(f.read())
    with open(OUT_ROOT + "/index.html", 'w') as fw:
        fw.write(template.render(projects=PROJECTS))
