# Bacon Patches
These are one-time use patches to correct fixes until new releases can permanently address the issue

# Contents
| Patch    | Bacon Ver          | Purpose                           | CVE        | Notes                                           | File                       | Public Release? | Server Fix | Endpoint Fix |
|----------|--------------------|-----------------------------------|------------|-------------------------------------------------|----------------------------|-----------------|---|----|
| 20210112 | 1.5.0 >= v < 1.5.7 | Deleting Uncleared DB connections |            | Installed by Bacon engineer as cron job on host | bacon_patch.01.20210112.py |                 | y |  |
| 20211222 | 2.0 >= v < 3.0     | Security Update for NGINX         | 2021_23017 | One time run, on the Bacon server host.         | cve_2021_23017.sh          | Yes             | y |  |
