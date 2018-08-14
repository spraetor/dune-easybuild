## EasyBuild
Description from http://easybuild.readthedocs.io/en/latest/index.html

> EasyBuild: a software build and installation framework that allows you to manage 
> (scientific) software on High Performance Computing (HPC) systems in an efficient way.

It allows to automate the build and install process in HPC systems.

## Installing dune with EasyBuild
The dune modules itself depend on each other. This dependency can be resolved 
either using `dunecontrol` or using `EasyBuild`. The latter allows to also
resolve dependencies to external software installed in an HPC cluster, that 
needs access to a module system for the resolution.  An EasyConfig file describes
these dependencies and gives control over the build and installation process.

```
module load EasyBuild
```

Simply build the (meta) dune module that has dependencies to all other dune
modules or build each one separately:

```
eb dune-2.6.0-foss-2018a.eb --robot=external/:modules/ --moduleclasses=dune
```

The option `--robot` enables dependency resolution with the parameter `--robot=DIR` 
adds `DIR` to the search path for EasyConfig files, and finally the options 
`--modulesclasses=dune` adds an additional Environmental module subdirectory 
`dune` where all dune modules are stored in.

## Creating new EasyConfig files
EasyConfig files are simple text files with some python syntax. Updating a version
of a dune module could be done, by copying the EasyConfig file, changing the version 
number and updating the checksum:

```
eb EASYCONFIGFILE.eb --inject-checksums
```

If you want to base your installatio on the current git branch, use the `duneeasyconfig.sh`
script that prepares the git master branch for a use with EasyBuild. It creates
automatically an EasyConfig file, downloads the files, and creates an archive
of the downloaded data.

```
tools/duneeasyconfig.sh dune-foamgrid extensions
```