# Design considerations

## Options

-   EasyBuild-managed software:

    -   **Option 1**: modules, software and ebrepo at the bottom of the
        directory hierarchy. So each of these directories than have
        subdirectories for the various versions of the stack and various
        hardware/OS architectures.

        -   The advantage is that we can keep the length of the path for
            the software minimal by using abbreviations while we can use
            more readable names for the modules and ebrepo directories.

        -   May also be easier to integrate with the current setup for
            software that is already installed.

    -  ** Option 2a**: First subdirectories per version of the stack,
        hardware/OS and then modules/software/ebrepo_files

    -   **Option 2b**: hardware/OS, then version of the stack, then
        modules/software/ebrepo_files

        -   This goes contrary to the LMOD hierarchy, though this
            shouldn’t really matter as it is only important for the
            infrastructure modules.

    -   We should not forget that there is also software outside the
        stack, generic x86, which is systemwide available.

-   Note that besides the EasyBuild modules, we still need the
    infrastructure tree (as on LUMI) to get everything to work correctly.

    The infrastructure module tree follows a strict Lmod hierarchy whereas the
    tree with EasyBuild-generated modules does not. The infrastructure tree does,
    e.g., contain the EasyBuild configuration modules and only one subdirectory of 
    it can be in the `MODULEPATH` at any given time.

-   Which elements determine the architecture string?

    -   OS version: certainly

    -   CPU architecture: certainly. Propose to use the names that are
        also used in archspec.

    -   Do we want to include GPU architecture?

        -   And if so, build upon an existing stack which saves disk
            space but adds complications in the modules and the risk
            that dependencies get installed in the wrong place when
            using eb -r?

    -   Do we want to include the interconnect?

        -   EESSI doesn’t distinguish between interconnects as they
            manage to build an MPI that works on Ethernet, InfiniBand
            and Omni-Path, though it remains to be seen if they can
            adapt to Slingshot also…

        -   It is only really important if we would have CPUs of the
            same generation with a different interconnect.

        -   It can be added later, though it would mean that sometimes
            the interconnect is in the architecture string and sometimes
            it is not (which I think happened in Brussels).

-   Separate repository for everything related to LMOD settings and
    generic modules to select the version of the software tree and do
    the EasyBuild settings?

-   A single EasyBuild repository with everything or as now different
    repositories?

-   Where do we put manually installed software?

-   A common architecture to install tools that only depend on OS (or
    even not that) such as EasyBuild itself, or simply have multiple
    copies of these tools also?

    -   Gent does the latter to keep it simple, on LUMI we do the former
        to save a bit on the number of files given the load that lots of
        small files put on a parallel file system.


## More detailed layout

### Option 1

```bash
apps    
└─ antwerpen  
   └─ CalcUA  
      ├─ UAntwerpen-modules**: Repository with LMOD configuration and generic modules  
      ├─ UAntwerpen-easybuild: EasyBuild setup  
      │  └─ easybuild  
      │     ├─ easyconfigs  
      │     ├─ easyblocks  
      │     ├─ Customisations to naming schemes etc.  
      │     └─ config: Configuration files for some settings not done via environment  
      ├─ modules-infrastructure: The structure of modules to select the version etc., in a LMOD hierarchy  
      │  ├─ stacks  
      │  │  └─ calcua  
      │  │     └─ 2021b.lua: Symbolic link to a generic module!  
      │  ├─ arch  
      │  │  └─ calcua  
      │  │     └─ 2021b  
      │  │        ├─ cluster  
      │  │        │  ├─ hopper.lua: Symbolic link to a generic module!  
      │  │        │  ├─ leibniz.lua  
      │  │        │  ├─ leibniz-skl.lua  
      │  │        │  ├─ vaughan.lua  
      │  │        │  └─ generic.lua  
      │  │        └─ arch  
      │  │           ├─ redhat8  
      │  │           ├─ redhat8-broadwell  
      │  │           └─ redhat8-broadwell-quadro  
      │  └─ infrastructure  
      │     └─ CalcUA  
      │        └─ 2021b  
      │           └─ arch  
      │              └─ redhat8-ivybridge  
      │                 ├─ EasyBuild-production  
      │                 ├─ EasyBuild-infrastructure  
      │                 └─ EasyBuild-user  
      ├─ modules-easybuild  
      │  ├─ CalcUA-2021b  
      │  │  ├─ redhat8_x86_64 : Directory for potential generic builds if performance does not matter  
      │  │  ├─ redhat8-broadwell  
      │  │  └─ redhat8-broadwell-quadro  
      │  └─ system: Modules outside the regular software stacks  
      │     ├─ redhat8 : No specific processor versions, e.g., Matlab  
      │     └─ redhat8-ivybridge: Specific processor version, e.g., Gaussian  
      └─ SW  
         ├─ CalcUA-2021b  
         │  ├─ RH8-x86_64  
         │  ├─ RH8-BRW  
         │  └─ RH8-BRW-NVGP61GL  
         ├─ system : Sometimes relatively empty subdirs if EasyBuild only creates a module.  
         │  ├─ RH8  
         │  └─ RH8-IVB  
         └─ MNL : Manually installed software. Do we need an OS level?  Probably best  
            └─ RH8-x86_86  
```

### Option 2a

```bash
apps
└─ antwerpen  
   └─ CalcUA  
      ├─ UAntwerpen-modules: Repository with LMOD configuration and generic modules  
      ├─ UAntwerpen-easybuild: EasyBuild setup  
      │  └─ easybuild  
      │     ├─ easyconfigs  
      │     ├─ easyblocks  
      │     ├─ Customisations to naming schemes etc.  
      │     └─ config: Configuration files for some settings not done via environment  
      ├─ modules-infrastructure: The structure of modules to select the version etc.  
      │  ├─ stacks  
      │  │  └─ calcua  
      │  │     └─ 2021b.lua: Symbolic link to a generic module!  
      │  ├- arch  
      │  │  └─ calcua  
      │  │       └─ 2021b  
      │  │          └─ cluster  
      │  │             ├─ hopper.lua: Symbolic link to a generic module!  
      │  │             ├─ leibniz.lua  
      │  │             ├─ leibniz-skl.lua  
      │  │             ├─ vaughan.lua  
      │  │             └─ generic.lua  
      │  └─ infrastructure  
      │     └─ CalcUA  
      │          └─ 2021b  
      │             └─ arch  
      │                └─ ivybridge-redhat8  
      │                   ├─ EasyBuild-production  
      │                   ├─ EasyBuild-infrastructure  
      │                   └─ EasyBuild-user  
      └─ 2021b  
          ├─ ivybridge-redhat8*  
          │  ├─ software  
          │  ├─ modules  
          │  └─ ebrepo_files  
          ├─ haswell-redhat8  
          ├─ skylake-redhat8 : Not exactly archspec, then it should be skylake_avx512-redhat8  
          ├─ zen2-redhat8  
          └─ 86_64-redhat8 ????? (In archspecL x86_64_v2 for IVB, x86_64_v3 for rome/BDW  
```

And we may need a directory for automatically generated files (needed on
LUMI but may not be needed in Antwerp)

-   Note for the `cluster` modules: Should we also include the OS in the
    naming scheme (e.g., to keep software for an old OS available at
    your own risk)? So far we have seen that MPI software for CentOS 7
    breaks on CentOS 8 so it is probably a support nightmare…

    -   It may matter at times when we switch the OS to a new version
        though I think this can be solved easily even in a generic
        module by temporary adding modules such as
        cluster/leibniz-CentOS7 etc.
