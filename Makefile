
# Use ?= to allow override from the env or command-line.

CC ?=		cc
CXX ?= 		c++
CXXFLAGS ?=	-g -Wall -O2 #-m64 #-arch ppc
CXXFLAGS +=	-fPIC
INCLUDES ?=	-Ihtslib
HTS_HEADERS ?=	htslib/htslib/bgzf.h htslib/htslib/tbx.h
HTS_LIB ?=	htslib/libhts.a
LIBPATH ?=	-L. -Lhtslib

DESTDIR ?=	stage
PREFIX ?=	/usr/local
STRIP ?=	strip
INSTALL ?=	install -c
MKDIR ?=	mkdir -p
AR ?=		ar

DFLAGS =	-D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE
BIN =		tabix++
LIB =		libtabix.a
SLIB =		libtabix.so
OBJS =		tabix.o
SUBDIRS =	.

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

all:	$(BIN) $(LIB) $(SLIB)

tabix.o: $(HTS_HEADERS) tabix.cpp tabix.hpp
	$(CXX) $(CXXFLAGS) -c tabix.cpp $(INCLUDES)

htslib/libhts.a:
	cd htslib && $(MAKE) lib-static

$(LIB): $(OBJS)
	$(AR) rs $(LIB) $(OBJS)

$(SLIB): $(OBJS)
	$(CXX) -shared -Wl,-soname,$(SLIB).1 -o $(SLIB) $(OBJS)

tabix++: $(OBJS) main.cpp $(HTS_LIB)
	$(CXX) $(CXXFLAGS) -o $@ main.cpp $(OBJS) $(INCLUDES) $(LIBPATH) \
		-lhts -lpthread -lm -lz

install: all
	$(MKDIR) $(DESTDIR)$(PREFIX)/bin
	$(MKDIR) $(DESTDIR)$(PREFIX)/include
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib
	$(INSTALL) $(BIN) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) *.hpp $(DESTDIR)$(PREFIX)/include
	$(INSTALL) $(LIB) $(DESTDIR)$(PREFIX)/lib

install-strip: install
	$(STRIP) $(DESTDIR)$(PREFIX)/bin/$(BIN)

cleanlocal:
	rm -rf $(BIN) $(LIB) $(SLIB) $(OBJS) $(DESTDIR)
	rm -fr gmon.out *.o a.out *.dSYM $(BIN) *~ *.a tabix.aux tabix.log \
		tabix.pdf *.class libtabix.*.dylib libtabix.so*
	cd htslib && $(MAKE) clean

clean:	cleanlocal-recur
