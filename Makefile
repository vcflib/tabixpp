
# Use ?= to allow override from the env or command-line.

CC?=		gcc
CXX?= 		g++
CXXFLAGS?=	-g -Wall -O2 -fPIC #-m64 #-arch ppc
INCLUDES?=	-Ihtslib
HTS_HEADERS?=	htslib/htslib/bgzf.h htslib/htslib/tbx.h
HTS_LIB?=	htslib/libhts.a
LIBPATH?=	-L. -Lhtslib

DFLAGS=		-D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE
PROG=		tabix++
SUBDIRS=.

.SUFFIXES:.c .o

.c.o:
	$(CC) -c $(CXXFLAGS) $(DFLAGS) $(INCLUDES) $< -o $@

all-recur lib-recur clean-recur cleanlocal-recur install-recur:
	@target=`echo $@ | sed s/-recur//`; \
	wdir=`pwd`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
		cd $$subdir; \
		$(MAKE) CC="$(CC)" DFLAGS="$(DFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
			INCLUDES="$(INCLUDES)" LIBPATH="$(LIBPATH)" $$target \
			|| exit 1; \
		cd $$wdir; \
	done;

all:	$(PROG)

tabix.o: $(HTS_HEADERS) tabix.cpp tabix.hpp
	$(CXX) $(CXXFLAGS) -c tabix.cpp $(INCLUDES)

htslib/libhts.a:
	cd htslib && $(MAKE) lib-static

tabix++: tabix.o main.cpp $(HTS_LIB)
	$(CXX) $(CXXFLAGS) -o $@ main.cpp tabix.o $(INCLUDES) $(LIBPATH) \
		-lhts -lpthread -lm -lz

cleanlocal:
	rm -fr gmon.out *.o a.out *.dSYM $(PROG) *~ *.a tabix.aux tabix.log \
		tabix.pdf *.class libtabix.*.dylib libtabix.so*
	cd htslib && $(MAKE) clean

clean:cleanlocal-recur
