#include "tabix.hpp"

Tabix::Tabix(void) { }

Tabix::Tabix(string& file) {
    filename = file;
    const char* cfilename = file.c_str();
    struct stat stat_tbi,stat_vcf;
    char *fnidx = (char*) calloc(strlen(cfilename) + 5, 1);
    strcat(strcpy(fnidx, cfilename), ".tbi");
    if ( bgzf_is_bgzf(cfilename)!=1 )
    {
        cerr << "[tabix++] was bgzip used to compress this file? " << file << endl;
        free(fnidx);
        exit(1);
    }
    // Common source of errors: new VCF is used with an old index
    stat(fnidx, &stat_tbi);
    stat(cfilename, &stat_vcf);
    if ( stat_vcf.st_mtime > stat_tbi.st_mtime )
    {
        cerr << "[tabix++] the index file is older than the vcf file. Please use '-f' to overwrite or reindex." << endl;
        free(fnidx);
        exit(1);
    }
    free(fnidx);

    if ((fn = hts_open(cfilename, "r")) == 0) {
        cerr << "[tabix++] fail to open the data file." << endl;
        exit(1);
    }

    if ((idx = tbx_index_load(cfilename)) == NULL) {
        cerr << "[tabix++] failed to load the index file." << endl;
        exit(1);
    }

    idxconf = &tbx_conf_vcf;

    // set up the iterator, defaults to the beginning
    iter = tbx_itr_queryi(idx, 0, 0, 0);

}

Tabix::~Tabix(void) {
    tbx_itr_destroy(iter);
    tbx_destroy(idx);
}


void Tabix::getHeader(string& header) {
    header.clear();
    kstring_t str = {0,0,0};
    while ( hts_getline(fn, KS_SEP_LINE, &str) >= 0 ) {
        if ( !str.l || str.s[0]!=idx->conf.meta_char ) {
            break;
        } else {
            header += string(str.s);
            header += "\n";
        }
    }
    // reset iter
    tbx_itr_destroy(iter);
    iter = tbx_itr_queryi(idx, 0, 0, 0);
}

bool Tabix::setRegion(string& region) {
    tbx_itr_destroy(iter);;
    iter = tbx_itr_querys(idx, region.c_str());
    return true;
}

bool Tabix::getNextLine(string& line) {
    if (!firstline.empty()) {
        line = firstline; // recovers line read if header is parsed
        firstline.clear();
        return true;
    }
    kstring_t str = {0,0,0};
    if (iter && tbx_itr_next(fn, idx, iter, &str) >= 0) {
        line = string(str.s);
        return true;
    } else return false;
}
