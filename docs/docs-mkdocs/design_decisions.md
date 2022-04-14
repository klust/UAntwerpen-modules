# Design decisions

## Overview of decisions

-   Separate module roots for infrastructure modules that follow a strict
    Lmod hierarchy and for the easybuild-managed modules that are arranged 
    by software stack and architecture.

-   At the top of the hierarchy, in the installation root, we find the GitHub
    repositories with the module system and the EasyBuild configuration, the roots
    of the infrastructure module system and the EasyBuild module system, the software
    packages tree, and the EasyBuild repo of installed software.

    We have chosen this option to be able to use short names for software directories
    without reducing the readability of the names of the module file directories, and 
    as such also to keep the size of shebang lines with full pahts under control to not
    hit kernel-imposed limits.

    ***Repository part of the tree***  
    ``` bash
    apps
    └─ antwerpen
       └─ CalcUA
          ├─ UAntwerpen-modules #(1)
          └─ UAntwerpen-easybuild #(2)
             └─ easybuild
                ├─ easyconfigs
                ├─ easyblocks
                ├─ Customisations to naming schemes etc
                └─ config #(3)
    ```

    1.  Repository with LMOD configuration and generic modules
    2.  EasyBuild setup
    3.  Configuration files for some settings not done via environment

-   We distinguish between two types of system-wide installed software:

    -   Software installed via EasyBuild (though with some tricks)  That software appears
        in the EasyBuild-managed modules and EasyBuild repo also.

        The software is installed via a dummy version of the calcua software stack
        (`calcua/system`) with its own copy of EasyBuild.  

    -   Software installed without using EasyBuild, with modules that are generated 
        via dummy EasyConfig files in the EasyBuild hierarchy.

-   Infrastructure modules: `modules-infrastructure`

    -  The hierarchy is build using the long names for the architecture string

    -   `init-UAntwerpen-modules`: Outside the hierarchy: Subdirectory for the module(s) that 
        initialises the whole module setup.

        Loading the initialisation module enables loading of the next level, the software
        stack modules.

    -   `stacks` subdirectory contains the modules for the software stack, currently only
        `calcua` modules, but that leaves room for a different software stack, e.g., EESSI, 
        later onn.

        Loading of a `calcua` module enables the next level, loading of an architecture
        module.

    -   `arch` subdirectory contains the architecture modules (or cluster modules).

        2 levels of subdirectories before you reach the architecture modules:

        1.  Name of the stack: `calcua`
  
        2.  Version of the stack
       
        Modules named after the cluster could be easier to recognise for some users. However,
        it may also be tricky to implement. Instead we can also use cluster names as the version
        of the `arch` modules, and this is organised via `.modulerc.lua` files for each software
        stack in the `arch` module subdirectory.

        Loading an architecture module enables the next step in the hierarchy, loading the 
        infrastructure modules and software modules.

    -   `infrastructure` subdirectory then contains the specific infrastructure modules, e.g.,
        the EasyBuild configuration modules.

        4 levels of subdirectories before you reach the infrastructure modules

        1.  Name of the stack: `calcua`

        2.  Version of the stack

        3.  `arch`

        4.  Long name string of the architecture (OS-CPU-Accelerator except for OS-x86_64).


-   EasyBuild-managed modules: `modules-easybuild`

    Here we treat the system-wide installed software which is independent from any calcua software
    stack as a separate software stack without version  Architecture-wise both are treated the same,
    though we expect that most if not all system-wide installed software will be installed in a
    generic architecture subdirectory.

    2 levels before arriving at the actual infrastructure modules:

    1.  Name-version of the software stack, e.g., `calcua-2021b` or `system`

    2.  Architecture string

-   Manually managed modules: `modules-manual`

    A space to put modules for the manually installed software in case we want to hand-code 
    these modules rather then inject them elsewhere via EasyBuild.

    The precise structure will be determined when the need arrises.

-   This leads to the following view on the modules tree:

    ``` bash
    apps
    └─ antwerpen
       └─ CalcUA
          ├─ modules-infrastructure #(1)
          │  ├─ init-UAntwerpen-modules #(2)
          │  ├─ stacks #(3)
          │  │  └─ calcua
          │  │     └─ 2021b.lua #(4)
          │  ├─ arch #(5)
          │  │  └─ calcua
          │  │     └─ 2021b
          │  │        └─ arch
          │  │           ├─ redhat8-x86_64
          │  │           ├─ redhat8-broadwell-noaccel
          │  │           └─ redhat8-broadwell-quadro
          │  └─ infrastructure #(6)
          │     └─ CalcUA
          │        └─ 2021b
          │           └─ arch
          │               └─ redhat8-ivybridge-noaccel
          │                  ├─ EasyBuild-production
          │                  ├─ EasyBuild-infrastructure
          │                  └─ EasyBuild-user
          ├─ modules-easybuild #(7)
          │  ├─ CalcUA-2021b
          │  │  ├─ redhat8_x86_64 #(8)
          │  │  ├─ redhat8-broadwell-noaccel
          │  │  └─ redhat8-broadwell-quadro
          │  └─ system* #(9)!
          │     ├─ redhat8-x86_64 #(10)
          │     └─ redhat8-ivybridge-noaccel #(11)
          └─ modules-manual #(12)!
    ```
    
    1.  Lmod hierarchy as the framework of the module system 
    2.  Subdirectory for the startup module
    3.  First level: Software stack modules
    4.  Symbolic link to a generic module!
    5.  Second level: Architecture of the stack
    6.  Third level: Infrastructure modules, e.g., EasyBuild configuration
    7.  Modules generated with EasyBuild
    8.  Directory for potential generic builds if performance does not matter
    9.  Modules outside the regular software stacks
    10. No specific processor versions, e.g., Matlab
    11. Specific processor version, e.g., Gaussian
    12. Manually generated modules - OPTIONAL



-   Software directory `SW`

    This directory follows the same layout as the one for the EasyBuild-installed software,
    with two differences:

    1.  At the architecture level, the short architecture string is used to save space

    2.  There is yet another pseudo-stack for manually installed software, called `MNL`  

        This directory has no corresponding modules directory in the EasyBuild-managed directory
        as it is not managed at all by EasyBuild.

    ***Resulting structure of the software directory***  
    ``` bash
    apps
    └─ antwerpen
       └─ CalcUA
          └─ SW
             ├─ CalcUA-2021b
             │  ├─ RH8-x86_64
             │  ├─ RH8-BRW-host
             │  └─ RH8-BRW-NVGP61GL
             ├─ system #(1)
             │  ├─ RH8-x86_64
             │  └─ RH8-IVB-host
             └─ MNL #(2)
    ```
    
    1.  Sometimes relatively empty subdirs if EasyBuild only creates a module...
    2.  Manually installed software


-   `mgmt` subdirectory for all files that are somehow system-generated.

    Current subdirectories:

    -   `ebrepo_files`: EasyBuild repository, structured the same way as the `modules-easybuild`
        subdirectory.

    -   `lmod-cache`: Placeholder for Lmod cache files.

        Maybe we should follow the approach of TCL Environment Modules 5 and have a separate cache
        file per module subdirectory, or does this become too much? We can also go for one corresponding to each software stack and cluster architecture combination which would
        result in a single file per ( software stack, architecture) combination.

    ***Resulting structure of the management directory***  
    ``` bash
    apps
    └─ antwerpen
       └─ CalcUA
          └─ mgmt
             ├─ ebrepo_files
             │  ├─ CalcUA-2021b
             │  │ ├─ redhat8-x86_64
             │  │ └─ redhat8-broadwell-noaccel
             │  └─ system #(1)
             │     └─ redhat8-x86_64 #(2)
             └─ lmod_cache
    ```
    
    1.  Modules outside the regular software stacks
    2.  No specific processor versions, e.g., Matlab


