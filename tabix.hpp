#include <string>
#include <stdlib.h>
#include <sys/stat.h>
#include <htslib/bgzf.h>
#include <htslib/tbx.h>
#include <htslib/kseq.h>
#include <iostream>
#include <cstring>
#include <vector>


namespace tabixpp {

    class Tabix {

        htsFile* fn;
        tbx_t* tbx;
        kstring_t str;
        hts_itr_t* iter;
        const tbx_conf_t *idxconf;
        int tid, beg, end;
        std::string firstline;
        bool has_jumped;
        std::vector<std::string>::iterator current_chrom;

    public:

        std::string filename;
        std::vector<std::string> chroms;

        Tabix(void);
        Tabix(const std::string& file);
        ~Tabix(void);

        void getHeader(std::string& header);
        bool setRegion(const std::string& region);
        bool getNextLine(std::string& line);
    };
}
