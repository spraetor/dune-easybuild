import re
import sys

version_pattern = re.compile('([0-9]+)\.([0-9]+)(?:\.([0-9]+))?')
depends_pattern = re.compile('([a-zA-Z_-]+)(?:[ ]*\(([<>=]+)[ ]*([0-9.]+)\))?')

def make_version(version, mod_version, fixed_version):
  if fixed_version:
    return fixed_version
  elif version:
    m = version_pattern.match(version)
    return m.group(1) + '.' + m.group(2) + '.' + (m.group(3) if m.group(3) is not None else '0')
  else:
    return mod_version


if len(sys.argv) < 2:
  print('usage: ' + sys.argv[0] + ' dune.module [fixed_version]')
  exit(1)


Module = None
Version = None
Depends = None
Suggests = None
with open(sys.argv[1]) as modulefile:
  for line in modulefile:
    dep = 'Depends'
    sug = 'Suggests'
    ver = 'Version'
    mod = 'Module'
    if line[0:len(dep)] == dep:
      Depends = line[len(dep)+1:-1].strip()
    elif line[0:len(sug)] == sug:
      Suggests = line[len(sug)+1:-1].strip()
    elif line[0:len(ver)] == ver:
      Version = line[len(ver)+1:-1].strip()
    elif line[0:len(mod)] == mod:
      Module = line[len(mod)+1:-1].strip()

fixed_version = None
if len(sys.argv) > 2:
  fixed_version = sys.argv[2]


Dependencies = []
if Depends:
  m = depends_pattern.findall(Depends)
  if m:
    for g in m:
      Dependencies.append((g[0],make_version(g[2],Version,fixed_version)))
if Suggests:
  m = depends_pattern.findall(Suggests)
  if m:
    for g in m:
      Dependencies.append((g[0],make_version(g[2],Version,fixed_version)))

for d in Dependencies:
  print("  ('" + d[0] + "', '" + d[1] + "'),")
