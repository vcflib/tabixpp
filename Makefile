CC=			gcc
CPP= 		g++
CFLAGS=		-g -Wall -O2 -fPIC #-m64 #-arch ppc
DFLAGS=		-D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE
PROG=		tabix++
INCLUDES=-Ihtslib
SUBDIRS=.
LIBPATH=-L. -Lhtslib

.SUFFIXES:.c .o

.c.o:
		$(CC) -c $(CFLAGS) $(DFLAGS) $(INCLUDES) $< -o $@

all-recur lib-recur clean-recur cleanlocal-recur install-recur:
		@target=`echo $@ | sed s/-recur//`; \
		wdir=`pwd`; \
		list='$(SUBDIRS)'; for subdir in $$list; do \
			cd $$subdir; \
			$(MAKE) CC="$(CC)" DFLAGS="$(DFLAGS)" CFLAGS="$(CFLAGS)" \
				INCLUDES="$(INCLUDES)" LIBPATH="$(LIBPATH)" $$target || exit 1; \
			cd $$wdir; \
		done;

all:$(PROG)

lib:libtabix.a

libtabix.a:$(LOBJS)
		$(AR) -cru $@ $(LOBJS)
		ranlib $@

tabix:lib $(AOBJS)
		$(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) -L. -lhts -lz

tabix.o: htslib/htslib/bgzf.h htslib/htslib/tbx.h tabix.cpp tabix.hpp
		$(CPP) $(CFLAGS) -c tabix.cpp $(INCLUDES)

htslib/libhts.a:
		cd htslib && $(MAKE) lib-static

tabix++:lib tabix.o main.cpp htslib/libhts.a
		$(CPP) $(CFLAGS) -o $@ main.cpp tabix.o $(INCLUDES) $(LIBPATH) -lhts -lpthread -lm -lz

cleanlocal:
		rm -fr gmon.out *.o a.out *.dSYM $(PROG) *~ *.a tabix.aux tabix.log tabix.pdf *.class libtabix.*.dylib libtabix.so*
		cd htslib && $(MAKE) clean

clean:cleanlocal-recur
