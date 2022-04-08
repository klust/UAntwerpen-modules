# The generic calcua and clusterarch modules

The calcua and clusterarch modules work together to load a version of the
software stack for the right architecture. Moreover they ensure that the
EasyBuild-config module can recover all the information it needs to install
software in the right directories.

The calcua module is loaded first. This module sets the version of the software
stack. The version of the software stack is of the form year followed by the letter
a or b.

**TODO**: Think about support for yyyy.mm also as this is used during the development
of new toolchains in EasyBuild itself, and also for EESSI.

The calcua modules will automatically load the best fitting clusterarch module
for the node on which the module is loaded. However, it is always possible to
overwrite that option later on.

Instances of the generic clusterarch module come in two shapes:
  * cluster/<name> or cluster/<name>-<OS> or cluster/<name>-<target> or
    cluster/<name>-<OS>-<target> or any other special designator: This is because
    users will typically be more familiar with the name of the cluster than with
    the CPU architecture. The mapping to CPU architecture is coded internally.
  * arch/<target> or arch/<OS>-<target>: This is a direct mapping
    to the underlying directory structure.
The <target> and <OS> fields correspond to what would be used in Spack,
with the exception that we use skylake instead of skylake_avx512.


## The calcua generic module






## The clusterarch generic module



## Clusterarch

This is a very complete list. Certainly initially some clusterarchs will be mapped
on others (e.g., no specific stacks on the GPU nodes) but this may be revised
over time.

Note for the long names:
  * The CPU target is based on the target that spack would report (or for that
    reason the archspec tool), except that we use skylake instead of
    skylake_avx512 and don't distinguish with Cascade Lake as that is just
    a different stepping fo the same CPU family and model.
  * The OS name is also based on what spack would report
In doing so, we hopefully ensure that the stack is future-proof and will
use similar naming as what would be used in Spack or in EESSI, as that also
follows these conventions for CPU targets. For the accelerators we've chosen
user-friendly names rather than their technical names.

Note for the short names:
  * For the AMD processors we simply refer to the zen name as that is
    already a very short name.
  * For the Intel processors we use established abbreviations: IVB for
    Ivy Bridge, BRW for Broadwell and SKLX for Skylake (in fact, the more
    often used abbreviation for Skylake with AVX512 is SKL-X but we want
    to avoid dashes in the name).
  * For the AMD GPUs we refer to their internal GFX code which is often
    used in architecture strings for compilers with OpenMP offload.
  * For NVIDIA GPUs we refer to their Compute Capability as that is
    a parameter that needs to be set when compiling. Furthermore we add "GL"
    to the string if it is a GPU for OpenGL visualisation. Hence:
      * The Ampere A100 becomes NVCC80 as it has compute capability 8.0.
      * The Tesla P100 becomes NVCC60 as it has compute capability 6.0.
      * The Quadro P5000 which is based on the GP104 chip becomes
        NVCC61GL as it has compute capability 6.1 and is also meant for
        visualisation with OpenGL.

These names are fixed in a function in `SitePackage.lua`.

| long                      | short             |
|:--------------------------|:------------------|
| redhat8-x86_64            | RH8-x86_64       |
| redhat8-zen2              | RH8-zen2         |
| redhat8-zen2-noaccel      | RH8-zen2-host    |
| redhat8-zen2-ampere       | RH8-zen2-NVCC80  |
| redhat8-zen2-arcturus     | RH8-zen2-GFX908  |
| redhat8-broadwell         | RH8-BRW          |
| redhat8-broadwell-noaccel | RH8-BRW-host     |
| redhat8-broadwell-P5000   | RH8-BRW-NVGP61GL |
| redhat8-broadwell-pascal  | RH8-BRW-NVCC60   |
| redhat8-ivybridge         | RH8-IVB          |
| redhat8-skylake           | RH8-SKLX         |
| redhat8-skylake-noaccel   | RH8-SKLX-host    |
| redhat8-skylake-aurora1   | RH8-SKLX-NEC1    |


### Possible names for cluster modules

  * cluster/hopper = arch/redhat8-ivybridge

  * cluster/leibniz = arch/redhat8-broadwell or arch/redhat8-broadwell-noaccel (depending
    on choices discussed further down)

  * cluster/leibniz-viz = arch/redhat8-broadwell-P5000

  * cluster/leibniz-nvidia = arch/redhat8-broadwell-pascal

  * cluster/vaughan = arch/redhat8-zen2 or arch/cents8-rome-noaccel

  * cluster/vaughn-amd = arch/redhat8-zen2-arcturus

  * cluster/vaughan-nvidia = arch/redhat8-zen2-ampere

  * cluster/biomina = arch/redhat8-skylake or arch/redhat8-skylake-noaccel depending
    on choices discussed further down

  * cluster/aurora = arch/redhat8-skylake-aurora1


## Node detection

### Based on names

It is difficult to get hostname and domain in one. `hostname -f` does not have the
desired effect on vaughan. One workaround is to use

```bash
host $(hostname -i) | awk '{print $NF }'
```

Results:

| Node type                  | `host $(hostname -i) \| awk '{print $NF }'` |
|:---------------------------|:--------------------------------------------|
| login node vaughan         | lnX.vaughan.antwerpenb.vsc                  |
| compute node vaughan       | rXcYYcnZ.vaughan.antwerpen.vsc              |
| NVIDIA node vaughan        | nvam1.vaughan.antwerpen.vsc                 |
| MI100 node vaughan         | amdarcX.vaughan.antwerpen.vsc               |
| login node leibniz         | lnX.leibniz.antwerpen.vsc                   |
| visualisation node leibniz | vizX.leibniz.antwerpen.vsc                  |
| compute node leibniz       | rXcYYcnZ.leibniz.antwerpen.vsc              |
| compute node hopper        | rXcYYcnZ.hopper.antwerpen.vsc               |
| Pascal node leibniz        | paX.leibniz.antwerpen.vsc                   |
| Aurora node leibniz        | aurora.leibniz.antwerpen.vsc                |
| Biomina node leibniz       | r0c03cZ.leibniz.antwerpen.vsc               |


### Based on VSC_ variables

  * Variables:

      * VSC_ARCH_LOCAL: Currently ivybridge, broadwell or rome.

          * The BioMina node also returns VSC_ARCH_LOCAL=broadwell...

          * What about the aurora node?

      * VSC_OS_LOCAL: centos7 or redhat8

  * It is not possible to detect the accelerator type


### Reading information in /proc etc.


  * Get the CPU type:

    ```bash
    cat /proc/cpuinfo | grep -m 1 "model name"  | cut -d : -f 2
    ```

    The only problem with this one is that it will still have a leading space but that
    is easily dealt with in the subsequent pattern matching to find the CPU family.

  * Instead of extracting the "model name" line one could also extract the "vendor_id",
    "cpu family" and "model" lines.

    E.g.,

      * AMD Rome: CPU family 23, model 49.
      * Intel Ivy Bridge: CPU family 6, model 62
      * Intel Broadwell: CPU family 6, model 79
      * Intel Skylake: CPU family 6, model 85
      * Intel Cascade Lake: Actually also CPU family 6, model 85, just a different
        stepping: 7 versus 4 for our Skylake CPUs

  * Accelerators can be detected by looking in the output of the lspci command

  * The OS can be detected from the variables that can be set through /etc/os-release,
    and in particular the NAME and VERSION_ID lines.


| Node type                  | vendor_id    | cpu family | model | lspci   |
|:---------------------------|:-------------|:-----------|:------|:--------|
| login node vaughan         | AuthenticAMD | 23         | 49    | /       |
| compute node vaughan       | AuthenticAMD | 23         | 49    | /       |
| NVIDIA node vaughan        | AuthenticAMD | 23         | 49    | /       |
| MI100 node vaughan         | AuthenticAMD | 23         | 49    | MI100   |
| login node leibniz         | GenuineIntel | 6          | 79    | GA100   |
| visualisation node leibniz | GenuineIntel | 6          | 79    | GP104GL |
| compute node leibniz       | GenuineIntel | 6          | 79    | /       |
| compute node hopper        | GenuineIntel | 6          | 62    | /       |
| Pascal node leibniz        | GenuineIntel | 6          | 79    | GP100GL |
| Aurora node leibniz        | GenuineIntel | 6          | 85    | NEC     |
| Biomina node leibniz       | GenuineIntel | 6          | 85    | /       |


### Final solution

The solution chosen was the last one, reading information from `/proc/cpuinfo`, `/etc/os-release`
and the output of `lspci`.


## Binary versions loaded by the cluster and arch modules

### Option 1: Maximal common installations

There are almost always three levels:

  * Level 1: Unoptimized generic x86 64-bit CPU

  * Level 2: Specific CPU architecture, but the package is fully GPU agnostic

  * Level 3: Specific CPU architecture and the package may have accelerated versions
    that we need to install with the same name.

Combinations:

  * login nodes and regular compute nodes vaughan: redhat8-zen2-noaccel, redhat8-zen2, redhat8-x86_64

  * NVIDIA nodes vaughan: redhat8-zen2-ampere, redhat8-zen2, redhat8-x86_64

  * MI100 nodes vaughan: redhat8-zen2-arcturus, redhat8-zen2, redhat8-x86_64

  * Regular login and compute nodes leibniz: redhat8-broadwell-noaccel, redhat8-broadwell, redhat8-x86_64

  * Visualisation node leibniz: redhat8-broadwell-P5000, redhat8-broadwell, redhat8-x86_64

  * Pascal node leibniz: redhat8-broadwell-pascal, redhat8-broadwell, redhat8-x86_64

  * BioMina node leibniz: redhat8-skylake-noaccel, redhat8-skylake, redhat8-x86_64

  * Aurora node leibniz: redhat8-skylake-aurora1, redhat8-skylake, redhat8-x86_64

  * Hopper node: redhat8-ivybridge, redhat8-x86_64

Advantages:

  * Minimal number of duplicated installations

Disadvantages:

  * Very easy to make mistakes about what to install where. No package should be installed with the same
    full name (name + version + versionsuffix) at multiple levels. No package can have
    dependencies at a higher level.

  * As it would be dangerous to have both an OpenMPI with and without accelerator support loaded, it means
    we have to install OpenMPI and all packages that depend on it at level 3, so we need to be very careful
    here.

      * Everything installed with Intel that does not need a GPU can be installed at level 2 as there is
        no GPU-specific Intel MPI.

      * With FOSS and its subtoolchains the situation is different. GCCcore and GCC can be installed at level
        1 or 2 but as long as we do not know if the EasyBuild community will succeed at building a single
        MPI module that works for everything, gompi and foss software should be installed at level 3.


### Option 2: Only common installations for software such as Matlab or maybe system toolchain

Now there are two levels:

  * Level 1: Unoptimized generic x86 64-bit CPU

  * Level 2: Optimised software

Combinations:

  * login nodes and regular compute nodes vaughan: redhat8-zen2-noaccel or redhat8-zen2, redhat8-x86_64

  * NVIDIA nodes vaughan: redhat8-zen2-ampere, redhat8-x86_64

  * MI100 nodes vaughan: redhat8-zen2-arcturus, redhat8-x86_64

  * Regular login and compute nodes leibniz: redhat8-broadwell-noaccel or redhat8-broadwell, redhat8-x86_64

  * Visualisation node leibniz: redhat8-broadwell-P5000, redhat8-x86_64

  * Pascal node leibniz: redhat8-broadwell-pascal, redhat8-x86_64

  * BioMina node leibniz: redhat8-skylake-noaccel or redhat8-skylake, redhat8-x86_64

  * Aurora node leibniz: redhat8-skylake-aurora1, redhat8-x86_64

  * Hopper node: redhat8-ivybridge, redhat8-x86_64

Users could in principle still use software from another architecture within the stack
by loading the appropriate clusterarch module so we could still be fairly selective
about what we provide for the "special" nodes with accelerators. However, many of the
often recurring dependencies like alternatives for what are often basic OS libraries
would have to be installed multiple times.

In this case the "noaccel" architecture isn't really needed unless we want all names
to have three components if they are on level 2 (which may ease a transition to option
1 later on).

Advantages

  * Conceptually certainly simpler as there is little doubt about where to install a module

Disadvantages

  * Larger volume of the overall software stack as more modules will be duplicated.
