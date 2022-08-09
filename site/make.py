#!/usr/bin/env python3

import json
import os
import shutil
import subprocess
import urllib.request

import yaml
from jinja2 import Template

from millify import millify

REPO_BLOB_URL = "https://github.com/eatonphil/tinyprograms/blob/main/"

REPO_ROOT = "."
NON_PROJECT_DIRS = [os.path.join(REPO_ROOT, r) for r in [
    "site",
    "scripts",
    ".git",
    ".github",
    "docs",
]]

OUT_ROOT = os.path.join(REPO_ROOT, "docs")
if os.path.exists(OUT_ROOT):
    shutil.rmtree(OUT_ROOT)
os.makedirs(OUT_ROOT)

def subdirs(path):
    for f in os.scandir(path):
        if f.is_dir():
            yield f.path

with open(os.path.join(REPO_ROOT, 'site/template.html')) as file_:
    template = Template(file_.read())

PROJECTS = {}

for project in subdirs(REPO_ROOT):
    if project in NON_PROJECT_DIRS:
        continue

    p_name = project.split('/')[-1]
    PROJECTS[p_name] = {
        "implementations": [],
    }

    for language in subdirs(os.path.join(REPO_ROOT, project)):
        if "_tests" in language:
            continue

        if not os.path.exists(os.path.join(language, "program.yaml")):
            continue

        l_name = language.split('/')[-1]
        PROJECTS[p_name]["implementations"].append(l_name)
        PROJECTS[p_name]["implementations"].sort()

    if len(PROJECTS[p_name]["implementations"]) == 0:
        del PROJECTS[p_name]

for project_name, project in PROJECTS.items():
    out = os.path.join(OUT_ROOT, project_name)
    if not os.path.exists(out):
        os.makedirs(out)

    for language in project["implementations"]:
        with open(os.path.join(REPO_ROOT, project_name, language, "program.yaml")) as f:
            program_desc = yaml.load(f, Loader=yaml.Loader)

        program = open(os.path.join(REPO_ROOT, project_name, language, program_desc["source"])).read()

        print("Writing {} page for {}".format(language, project_name))

        with open(os.path.join(OUT_ROOT, project_name, language + '.html'), 'w') as f:
            f.write(template.render(
                **program_desc,
                program=program,
                project_name=project_name,
                project=project,
                url=os.path.join(REPO_BLOB_URL, project_name, language, program_desc["source"]),
                run_step=(program_desc['run'][0] if isinstance(program_desc['run'], list) else program_desc['run']).format(PROGRAM="$myProgram"),
                language=language))

with open(os.path.join(REPO_ROOT, "site/index.html")) as f:
    template = Template(f.read())
    with open(os.path.join(OUT_ROOT, "index.html"), 'w') as fw:
        fw.write(template.render(projects=sorted(PROJECTS.items())))

with open(os.path.join(REPO_ROOT, "site/stars.html")) as f:
    stars_html = f.read()

    repo = json.load(urllib.request.urlopen("https://api.github.com/repos/eatonphil/tinyprograms"))
    stars = repo["stargazers_count"]
    formatted_stars = millify(str(stars), precision=1)

    with open(os.path.join(OUT_ROOT, "stars.html"), "w") as fw:
        fw.write(stars_html.replace("STARS", formatted_stars))

STATIC_FILES = ["style.css", "CNAME"]
for sf in STATIC_FILES:
    shutil.copyfile(os.path.join(REPO_ROOT, "site", sf), os.path.join(OUT_ROOT, sf))
