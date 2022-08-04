import os

from jinja2 import Template

REPO_ROOT = "../"
NON_PROJECT_DIRS = [
    "site",
    "scripts",
]

for project in os.listdir(REPO_ROOT):
    if project in NON_PROJECT_DIRS:
        continue

    for language in os.listdir(REPO_ROOT + project):
        if language == "_tests":
            continue

        

with open('template.html.jinja2') as file_:
    template = Template(file_.read())

    template.render(name='John')
