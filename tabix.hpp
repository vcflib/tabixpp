#pragma once

#include <string>
#include <stdlib.h>
#include <sys/stat.h>
#include "htslib/bgzf.h"
#include "htslib/tbx.h"
#include "htslib/kseq.h"
#include "htslib/hfile.h"
#include <iostream>
#include <cstring>
#include <vector>


using namespace std;

class Tabix {

    htsFile* fn;
    tbx_t* tbx;
    kstring_t str;
    hts_itr_t* iter;
    const tbx_conf_t *idxconf;
    int tid, beg, end;
    string firstline;
    bool has_jumped;
    vector<string>::iterator current_chrom;

    /* uncompressed file pos
    off_t hts_utell1(htsFile *fp)
        {
            if (fp->is_bgzf) {
                return bgzf_htell(fp->fp.bgzf);
            }
            else
                return htell(fp->fp.hfile);
        }
    */

    // Get file position in compressed file - really on disk
    off_t bgzf_htell1(BGZF *fp) {
        if (fp->mt) {
            return -1; // skip if multithreading
            //pthread_mutex_lock(&fp->mt->job_pool_m);
            //off_t pos = fp->block_address + fp->block_clength;
            //pthread_mutex_unlock(&fp->mt->job_pool_m);
            //return pos;
        } else {
            return htell(fp->fp);
        }
}

public:
    string filename;
    vector<string> chroms;

    Tabix(void);
    Tabix(string& file);
    ~Tabix(void);

    const kstring_t * getKstringPtr();
    void getHeader(string& header);
    bool setRegion(string& region);
    bool getNextLine(string& line);
    bool getNextLineKS();
    // Specialised function gets actual file position when using bgzf
    long file_pos() { return bgzf_htell1(fn->fp.bgzf); };
};
