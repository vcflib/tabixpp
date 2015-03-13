#include <string>
#include <stdlib.h>
#include <sys/stat.h>
#include "htslib/bgzf.h"
#include "htslib/tbx.h"
#include "htslib/kseq.h"
#include <iostream>
#include <cstring>


using namespace std;

class Tabix {

    htsFile* fn;
    tbx_t* idx;
    hts_itr_t* iter;
    const tbx_conf_t *idxconf;
    int tid, beg, end;
    string firstline;

public:

    string filename;

    Tabix(void);
    Tabix(string& file);
    ~Tabix(void);

    void getHeader(string& header);
    bool setRegion(string& region);
    bool getNextLine(string& line);

};
