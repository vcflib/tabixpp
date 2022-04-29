;; To use this file to build HEAD of tabixpp:
;;
;;   guix build -f guix.scm
;;
;; To get a development container (emacs shell will work)
;;
;;   guix shell -C -D -f guix.scm
;;
;; For the tests you need /usr/bin/env. In a container create it with
;;
;;   mkdir -p /usr/bin ; ln -s $GUIX_ENVIRONMENT/bin/env /usr/bin/env
;;
;; or in one go
;;
;;   guix shell -C -D -f guix.scm -- bash --init-file <(echo "mkdir -p /usr/bin && ln -s \$GUIX_ENVIRONMENT/bin/env /usr/bin/env")
;;
;;   make CC=gcc -j 16

(use-modules
  ((guix licenses) #:prefix license:)
  (guix gexp)
  (guix packages)
  (guix git-download)
  (guix build-system cmake)
  (gnu packages algebra)
  (gnu packages base)
  (gnu packages compression)
  (gnu packages bioinformatics)
  (gnu packages build-tools)
  (gnu packages curl)
  (gnu packages gcc)
  (gnu packages gdb)
  (gnu packages haskell-xyz) ; pandoc for help files
  (gnu packages llvm)
  (gnu packages parallel)
  (gnu packages perl)
  (gnu packages perl6)
  (gnu packages pkg-config)
  (gnu packages python)
  (gnu packages python-xyz) ; for pybind11
  (gnu packages ruby)
  (gnu packages version-control)
  (srfi srfi-1)
  (ice-9 popen)
  (ice-9 rdelim))

(define %source-dir (dirname (current-filename)))

(define %git-commit
    (read-string (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2" OPEN_READ)))

(define-public tabixpp-git
  (package
    (name "tabixpp-git")
    (version (git-version "1.0.0" "HEAD" %git-commit))
    (source (local-file %source-dir #:recursive? #t))
    (build-system cmake-build-system)
    (inputs
     `(("curl" ,curl)
       ("gcc" ,gcc-11)    ;; test
       ("gdb" ,gdb)
       ;; ("htslib" ,htslib)
       ;; ("tabixpp" ,tabixpp)
       ("xz" ,xz)
       ("zlib" ,zlib)))
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("git" ,git)))
    (home-page "https://github.com/tabixpp/tabixpp/")
    (synopsis "C++ wrapper library for tabix")
    (description "
C++ wrapper around tabix project which abstracts some of the details of opening and jumping in tabix-indexed files.")
    (license license:expat)))

tabixpp-git
