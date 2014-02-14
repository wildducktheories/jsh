NAME
===
jsh - jon's (s)hell - a package management system for bash.

DESCRIPTION
===========
The goal of this project is to provide a package management system for managing bash modules and so allow the development and sharing of relatively large collections of bash functions 
that project teams might find useful for managing their own command line scripting needs.

jsh assists with the distribution, discovery, local management and invocation of bash functions organised into packages of modules.

A package is the smallest unit of distribution and deployment. A package consists of a top-level module, zero or more sub-modules and zero or more sub-packages. 
Each module is implemented by a bash function which is located within top-level module of a package or in a .j module file within a package. Following brew, but with some differences, 
jsh uses git to manage the distribution of packages.

OPERATION
=========
From the perspective of a jsh user, the functionality of each activated package is represented by a command on the path named after the package. The functionality provided by a package can itself
be subdivided into modules each of which is addressed by adding a command argument which names the module. The functionality provided by a module can be further subdivided into submodules (or sub packages) each of which is addressed by appending yet additional command arguments which name the sub-module or sub-package. 

So, for example, to invoke a command that reports the location of the current jsh installation tree, a user might type:

    jsh installation top

'jsh' is a command that addresses a package called 'jsh'; 'installation' is a command that addresses a module, called 'installation' inside the 'jsh' package; 'top' is a command that addresses a sub-module called 'top'.

The jsh installation will resolve each command in turn, ultimately loading and executing a function called '\_top' nested within a function called '\_installation' found in a module file called 'installation.j' found in a package directory called 'jsh'.

INSTALLATION TREE
=================
jsh operates with the assumption of the existence of installation tree. The function of the installation tree is to provide a uniform namespace to organise the various 
storage and configuration needs of individual jsh packages. jsh recognises three kinds of storage requirement: package storage, local configuration storage and local object storage. 

Package storage refers to the storage of package artifacts themselves and is typically managed with git. Configuration storage is local storage used to store configuration used by jsh packages 
and is expected to vary on a per installation basis. Local object storage is storage used for arbitrary purposes.

The jsh installation tree has the following structure:

* bin/{package} - a link to ../mnt/jsh/resolved-packages/jsh/j.sh which will invoke the top level module of {package}
* etc/{package} - a directory (or link to a directory) for the local configuration associated with {package}
* mnt/{package} - a link to the actual location of the local object storage associated with {package}. usually defaults to ../var/{package}
* var/{package} - the default location of local object storage associated with {package}
* mnt/jsh/dist/{nnnn}-{dist}/{package} - package storage for the contents of a package found in one distribution
* mnt/jsh/resolved-packages/{package} - contains a link to an actual package implementation in mnt/jsh/dist/{nnnn}-{dist}/{package}
* mnt/jsh/resolved-packages/{package}/{package}.j - a bash source file containing a function called _{package} containing the top-level module of the package
* mnt/jsh/resolved-packages/{package}/{module}.j - a bash source file containing a function called _{module} containing another module in a package
* mnt/jsh/resolved-packages/{package}/{subpackage}/{subpackage}.j - a bash source file containing a function called _{subpackage} containing the top-level module of a sub-package
* mnt/jsh/resolved-packages/{package}/doc/md/{module}.md - the markdown markup for a module document
* mnt/jsh/resolved-packages/{package}/doc/html/{module}.html - the (generated) HTML markup for a module document
* mnt/jsh/doc/html/{package} - a link to the generated HTML documentation for a package

DISTRIBUTION
==========
A distribution is a collection of packages.

A installation tree will typically contain several distributions some of which may contain packages with identical names. In this case, the package implementation that occurs in the distribution whose name is first in the lexical order of all distributions found in mnt/jsh/dist is the one that wins.

Distributions are managed by a manager who is responsible for determining the composition and versions of each package in the distrbution.

A distribution is typically implemented as a git superproject with each package being implemented a git submodule. git facilities are used to manage the freshness of packages with respect to an upstream repository.

PACKAGE
=======
A jsh package, {p}, is directory consisting of:

* a single top-level module file {p}.j containing the definition of the package's top-level module
* one or more sub-module files, {m}.j, containing the definition of the package's sub-modules
* one or more sub-package directories, {s}, containing the the package's sub-packages
* other package-specific files located in package storage

Packages are grouped into distributions. Distrbutions and packages can either be managed or unmanaged. Managed distrbutions and packages are managed using git. Unmanaged packages and distributions are not managed with git.

Packages may exist in one of 4 states:

* available - the package exists in a remote git repository, but the submodule containing the package has not been initialised and updated
* cached - the submodule containing the package is initialised and updated but not otherwise activated
* active - the submodule containing the package is initialised and updated, a link representing the package has been added to the installation tree's bin directory and link to the package
directory from the mnt/jsh/resolved-packages has been established
* broken - some aspect of the jsh package management invariants are broken

MODULE
======
A jsh module, {m}, is a function called \_{m}. The source for a module is either nested within the source of a parent module or within .j file within some package. The body of module
may declare other modules or functions. Modules that declare other modules in their body usually pass their arguments to jsh invoke in order to allow for recursive dispatch.

All packages MUST have at least one module, called the top-level module, which has the same name as the package. The source for this module MUST be located in a consistently named module file 
in the top directory of the package. The top-level module is special because it is the first module in a package that is invoked by the command that represents the package.

DOCUMENTATION
=============
Documentation of packages is managed with a slight variant markdown.

TERMINOLOGY
===========

* resolved-packages-directory
	A directory containing links to packages. Ambiguous package selections have been resolved.

* distribution
	A directory containing zero or more packages. 

* package
	A directory within a repository containing one or more modules. If the package is called {p} then there MUST be top-level module called {p}.

* sub-package
	A directory within a package directory which also satisfies the defintion of a package. That is, if the directory is called {d} and {d}/{d}.j also
	exists, then {d} is a sub package.

* module
	A bash function. If the module is called {m}, then the implementing function is called _{m}() and is contained within a file called {m}.j or {m}/{m}.j

* module file
	A .j file, located in a package directory, that contains the definition of a module.

* top-level module
	A module with the same name as the containing package. Each package should have exactly one top-level module. 

* sub-module
	Any module in a package directory whose name does not match the name of the containing package.

CONVENTIONS
===========
* packages can reserve part of the global environent for themselves using a prefix.

BOOTSTRAP
=========

The following commands will install the jsh installation tree into ~/.jsh and then create links 
for the 'jsh' and 'scratch' packages in ~/bin. 

    mkdir -p ~/bin &&
    git clone https://github.com/wildducktheories/jsh-installation.git ~/.jsh && 
    cd ~/.jsh && 
    git submodule update --init --recursive &&
    mnt/jsh/resolved-packages/jsh/bin/j.sh jsh installation init ~/bin

If ~/bin is in your PATH, then:

    jsh installation top

should display the location that you cloned the jsh installation tree into.

The following will create a new 'foobar' module in the 'scratch' package.

    jsh module edit scratch foobar

To invoke the module, run:

    scratch foobar 

SUPPORTED COMMANDS
==================
The following is a list of commands that jsh supports out of the box. The list will be extended over time to provide more comprehensive management of packages.

jsh installation top
---------------
Output the top of the jsh installation directory.

jsh installation get bin
-------------------
Output the location of the installation bin directory.

jsh installation set bin {bindir}
-------------------------
Link the installation bin directory to the specified directory. {bindir} should be a directory, such as /usr/local/bin, which is in the PATH.

If {bindir} is the same as 'jsh installation top', then links are created in the {bindir} directory itself, rather than in some other directory. In this case, the caller should ensure 
that {bindir} is placed in the PATH.

jsh installation link bin
--------------------
Create a link from the installation bin directory to mnt/jsh/resolved-packages/jsh/bin/j.sh for each package in mnt/jsh/resolved-packages.

jsh installation init {bindir}
-------------------------
Invokes 'jsh installation set bin {binddir}' and 'jsh installation link bin'. 

jsh installation list resolved-packages
---------------------------------------
Outputs a list of the resolved packages in the installation.

jsh installation resolved-packages
---------------------------------------
Outputs the absolute path name of the installation's resolved packages directory.

jsh module filename {package} {module}...
-----------------------------------------
Outputs the name of the module file that contains the implementation of the specified module.

jsh module edit {package} {module}...
-------------------------------------
Invokes the program referred to by $EDITOR on the module file that implements the specified module.

jsh module create {package} {module}...
---------------------------------------
Create a new module file for the specified module path, then invokes the $EDITOR on that module.

jsh die {message-arg}...
------------------------
Output the remaining arguments to stderr, then exit the current shell with a non-zero status code.

jsh invoke {module}... {arg}...
-------------------------------
Invoke the specified submodule of the current package/submodule.

jsh debug {message-arg}...
--------------------------
If JSH_DEBUG is non empty, output the remaining arguments to stderr.

META MODULE
===========
Every package (and module) can define a submodule, called meta which can answer questions asked of the module by the jsh installation. 
This section will document the expected behaviour of each submodule of a module's meta module.

ENVIRONMENT
===========
All environment variables prefixed with JSH_ are reserved for use by modules in the jsh package and form part of the public interface of the jsh package.

All environment variables prefixed with _jsh are reserved for use by the implementation of jsh package and are not part of the public interface. Any use of these variables by
modules outside the jsh package is not supported.

JSH_DEBUG
---------
If this variable is not empty, the arguments to 'jsh debug' will be logged to stderr

REVISIONS
=========
14 Feb 2014

* fix some issues with the module stack
* add support 'jsh debug'
* change license from GPLv3 to LGPLv3
* rename 'jsh runtime' to 'jsh installation'
* add support 'jsh installation resolved-packages'

13 Feb 2014

* Add GPLv3 license.
* Add initial installation support.
* Renamed 'repository' to 'distribution' to better reflect intent.
* Enable linking of package commands to existing bin directory

10 Feb 2014

* Initial version
