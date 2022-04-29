This is a C++ wrapper around [tabix project](http://samtools.sourceforge.net/tabix.shtml) which abstracts some of the details of opening and jumping in tabix-indexed files.

# Build

```sh
git submodule update --init --recursive
make CC=gcc -j 16
make test
```

See also [guix.scm](./guix.scm) for the build environment we test with.

# Dependencies

tabixpp has htslib as a dependency. If you want to build from the included submodule make sure that the following dependencies are available:

```
libcurl   libcurl - Library to transfer files with ftp, http, etc.
zlib      zlib - zlib compression library
liblzma   liblzma - General purpose data compression library
```

It is also possible to disable these inside htslib/config.h --- generated after the first build.


Author: Erik Garrison <erik.garrison@gmail.com>
