add_library(tabixpp
	bedidx.c
	bgzf.c
	bgzip.c
	index.c
	knetfile.c
	kstring.c
	tabix.cpp
)
target_link_libraries(tabixpp ${ZLIB})
