from subprocess import Popen, PIPE, STDOUT
import os
import json
from glob import glob
import textwrap
import re

pkgs = glob("pkg/*/PackageInfo.g")

gap_script = """
MakeReadWriteGlobal("SetPackageInfo");
a:=1;
SetPackageInfo:= function(n)
    a:=n;
end;
SizeScreen([10000, 10000]);
Read("pkg/{}/PackageInfo.g");
Print(a.PackageWWWHome, "\\n");
Print(a.Version, "\\n");
Print(a.Subtitle, "\\n");
Print(a.Dependencies.GAP, "\\n");
Print(a.Dependencies.NeededOtherPackages, "\\n");
Print(a.AbstractHTML, "\\n");
"""

def get_name(pkg_dir):
    pkg_name = pkg_dir.split("-")[0].lower()
    pkg_name = re.match("[a-z_0-9]*[a-z]", pkg_name)[0]
    return pkg_name

for pkg in pkgs:
    pkg_dir = pkg.split("/")[1]
    pkg_name = get_name(pkg_dir)
    print(f"        - {{{{ pin_subpackage('gap-{pkg_name}', max_pin='x.x.x') }}}}")

for pkg in pkgs:
    pkg_dir = pkg.split("/")[1]
    pkg_name = get_name(pkg_dir)
    p = Popen(['./gap', '-r', '-b', '-q'], stdout=PIPE, stdin=PIPE, stderr=PIPE)
    l = p.communicate(input=bytes(gap_script.format(pkg_dir), encoding='utf-8'))
    out=l[0].decode()
    lines = out.split("\n")[3:]
    home_page = lines[0]
    version = lines[1]
    summary = lines[2]
    gap_ver_req = lines[3].replace(" ", "")
    if not gap_ver_req.startswith(">"):
        gap_ver_req = ">=" + gap_ver_req
    gap_reqs = json.loads(lines[4])
    abstract = '\n        '.join(textwrap.wrap(' '.join(lines[5].split()), 72))
    conda_reqs = []
    if os.path.exists(os.path.join(pkg, "configure")):
        conda_reqs.append("{{ pin_subpackage('gap-core', max_pin='x.x.x') }}")
    else:
        conda_reqs.append(f"gap-core {gap_ver_req}")
    for req, ver in gap_reqs:
        if pkg_name == "polycyclic" and req.lower() == "alnuth":
            continue
        ver = ver.replace(" ", "")
        if not ver.startswith(">"):
            ver = ">=" + ver
        conda_reqs.append("gap-"+req.lower()+" "+ver)
    requirements = "\n      - ".join(conda_reqs)
    files = glob(f"pkg/{pkg_dir}/LICENSE*")
    files.extend(glob(f"pkg/{pkg_dir}/COPYING*"))
    if files:
        license_file = files[0]
    else:
        license_file = "LICENSE"
    template = f"""
  - name: gap-{pkg_name}
    script: install-pkg.sh
    version: "{version}"
    requirements:
      run:
      - {requirements}
    about:
      home: {home_page}
      license_file: {license_file}
      summary: {summary}
      description: |
        {abstract}"""
    print(template)
