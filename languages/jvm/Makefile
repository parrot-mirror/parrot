# #############################################################################
# JVM class To PIR Translator
# Copyright (C) Jonathan Worthington 2005, 2007
# Copyright (C) 2008, Reini Urban
# #############################################################################
# requires special treatment for: trans_mono_lib_path, trans_class_library, srm
# Configure.pl: generate_makefile

HLLNAME       = jvm

# BUILD TOOLS AND UTILITIES
# #########################
PERL          = /usr/bin/perl.exe
RM_F          = $(PERL) -MExtUtils::Command -e rm_f
CP            = $(PERL) -MExtUtils::Command -e cp
MKPATH        = $(PERL) -MExtUtils::Command -e mkpath
POD2MAN       = pod2man
BUILD_DIR     = /usr/src/perl/parrot/branches/cygwin070patches
MONOLIB       = ${trans_mono_lib_path}
#IF(cygwin):SHRPENV       = env PATH="/usr/src/perl/parrot/branches/cygwin070patches/blib/lib:$(PATH)"
#ELSIF(not win32):SHRPENV       = env LD_RUN_PATH="/usr/src/perl/parrot/branches/cygwin070patches/blib/lib"
PARROT        = $(SHRPENV) ../../parrot.exe
PBCMERGE      = $(SHRPENV) ../../pbc_merge.exe
PBC_TO_EXE    = $(SHRPENV) ../../pbc_to_exe.exe
BUILD_DYNPMC  = $(PERL) $(BUILD_DIR)/tools/build/dynpmc.pl
RECONFIGURE   = $(PERL) $(BUILD_DIR)/tools/dev/reconfigure.pl
OPSBUILD      = $(PERL) $(BUILD_DIR)/tools/build/dynoplibs.pl

# FILE EXTENSIONS
# ###############
LOAD_EXT      = .dll
O             = .o
A             = .a
EXE           = .exe


# DIRECTORIES AND FILES
# #####################
BIN_DIR       = /usr/bin
LIB_DIR       = /usr/lib
DOC_DIR       = /usr/share/doc/parrot
MANDIR	      = /usr/man
PARROT_DYNEXT = $(BUILD_DIR)/runtime/parrot/dynext
PARROT_LIB    = $(BUILD_DIR)/runtime/parrot/library
SRM_PATH      = $(BUILD_DIR)/lib/SRM
PMCDIR    = pmc
PMCS      = JavaClassFile JavaClassMetaData JavaMethodMetaData \
            JavaFieldMetaData JavaParamMetaData JavaSignature \
            JavaByteCode JavaTypeRefMetaData JavaMemberRefMetaData \
            JavaEH ManagedPointer JavaClassFileRef int64 uint64
PMC_FILES = pmc/JavaClassFile.pmc pmc/JavaClassMetaData.pmc \
            pmc/JavaMethodMetaData.pmc pmc/JavafieldMetaData.pmc \
            pmc/JavaParamMetaData.pmc pmc/JavaSignature.pmc \
            pmc/JavaByteCode.pmc pmc/JavaTypeRefMetaData.pmc \
            pmc/JavaMemberRefMetaData.pmc pmc/JavaEH.pmc \
            pmc/ManagedPointer.pmc pmc/JavaClassFileRef.pmc \
            pmc/int64.pmc pmc/uint64.pmc
OPSDIR    = ops
OPSLIB    = jvm
OPS_FILES = ops/jvm.ops
TRAN_PIR  = src/translator.pir src/method.pir src/signature.pir src/typeinfo.pir \
            src/field.pir src/exception.pir
TRAN_PBC  = src/translator.pbc src/method.pbc src/signature.pbc src/typeinfo.pbc \
            src/field.pbc src/exception.pbc


# BUILD TARGETS
# #############

build : class2pbc.pbc

all : Makefile pmc/jvm$(LOAD_EXT) ops/jvm_ops$(LOAD_EXT) src/it.pbc \
      src/builtins.pbc src/translib.pbc class2pbc.pbc

installable : class2pbc.pbc installable_class2pbc$(EXE)

pmc/jvm$(LOAD_EXT) : $(PMC_FILES) pmc/structures.h pmc/tableinfo.h
	@cd $(PMCDIR) && $(BUILD_DYNPMC) generate $(PMCS)
	@cd $(PMCDIR) && $(BUILD_DYNPMC) compile $(PMCS)
	@cd $(PMCDIR) && $(BUILD_DYNPMC) linklibs $(PMCS)
	@cd $(PMCDIR) && $(BUILD_DYNPMC) copy "--destination=$(PARROT_DYNEXT)" $(PMCS)

ops/jvm_ops$(LOAD_EXT) : $(OPS_FILES)
	@cd $(OPSDIR) && $(OPSBUILD) generate $(OPSLIB)
	@cd $(OPSDIR) && $(OPSBUILD) compile $(OPSLIB)
	@cd $(OPSDIR) && $(OPSBUILD) linklibs $(OPSLIB)
	@cd $(OPSDIR) && $(OPSBUILD) copy "--destination=$(PARROT_DYNEXT)" $(OPSLIB)

src/it.pbc : src/translation.rules
	$(PERL) $(SRM_PATH)/translator.pl src/translation.rules --srm OptRegister \
	  --output src/it.pir --config J2PConfig
	$(PARROT) -o src/it.pbc src/it.pir

src/builtins.pbc : src/builtins.pir
	$(PARROT) -o src/builtins.pbc src/builtins.pir

src/builtins.pir : src/internal.methods tools/builtins.pl
	$(PERL) tools/builtins.pl src/internal.methods --output src/builtins.pir

src/translib.pbc : src/it.pbc src/builtins.pbc $(TRAN_PBC)
	$(PBCMERGE) -o src/translib.pbc $(TRAN_PBC) src/it.pbc src/builtins.pbc

class2pbc.pbc : pmc/jvm$(LOAD_EXT) src/translib.pbc src/class2pbc.pbc
	$(PBCMERGE) -o class2pbc.pbc src/class2pbc.pbc src/translib.pbc

class-library : class2pbc.pbc
		echo Oops, I was not configured with the path to Java class library.


# regenerate the Makefile
Makefile: config/Makefile.in
	$(PERL) Configure.pl

class2pbc$(EXE) : class2pbc.pbc
	$(PBC_TO_EXE) class2pbc.pbc

installable_class2pbc$(EXE) : class2pbc.pbc
	$(PBC_TO_EXE) class2pbc.pbc --install


# PER FILE RULES AND DEPENDENCIES
# ###############################

src/class2pbc.pbc : src/class2pbc.pir
	$(PARROT) -o src/class2pbc.pbc src/class2pbc.pir

src/translator.pbc : src/translator.pir
	$(PARROT) -o src/translator.pbc src/translator.pir

src/method.pbc : src/method.pir
	$(PARROT) -o src/method.pbc src/method.pir

src/signature.pbc : src/signature.pir
	$(PARROT) -o src/signature.pbc src/signature.pir

src/typeinfo.pbc : src/typeinfo.pir
	$(PARROT) -o src/typeinfo.pbc src/typeinfo.pir

src/field.pbc : src/field.pir
	$(PARROT) -o src/field.pbc src/field.pir

src/exception.pbc : src/exception.pir
	$(PARROT) -o src/exception.pbc src/exception.pir

$(TRAN_PIR) :

src/translation.rules : 


# TEST TARGETS
# ############

test : all
	$(PERL) -It t/harness

# TODO: rename build_dir. basic run for missing libs
installable_test : installable
	./installable_class2pbc$(EXE)

install : all installable
	$(CP) installable_class2pbc$(EXE) $(DESTDIR)$(BIN_DIR)/parrot-class2pbc$(EXE)
	@cd $(PMCDIR) && $(BUILD_DYNPMC) copy "--destination=$(DESTDIR)$(LIB_DIR)/parrot/dynext" $(OPLIBS)
	@cd $(PMCDIR) && $(BUILD_DYNPMC) copy "--destination=$(DESTDIR)$(LIB_DIR)/parrot/dynext" $(PMCS)
	$(POD2MAN) doc/running.pod > $(DESTDIR)$(MANDIR)/man1/parrot-class2pbc.1
	$(MKPATH) $(DESTDIR)$(DOC_DIR)/languages/$(LANG)
	$(CP) $(DOCS) $(DESTDIR)$(DOC_DIR)/languages/$(LANG)
	$(CP) doc/*.pod $(DESTDIR)$(DOC_DIR)/languages/$(LANG)
	$(MKPATH) $(DESTDIR)$(DOC_DIR)/languages/$(LANG)/constructs
	$(CP) doc/constructs/.pod $(DESTDIR)$(DOC_DIR)/languages/$(LANG)/constructs

# CLEANUP TARGETS
# ###############

CLEANERS = \
 "$(PMCDIR)/jvm*.h" \
 "$(PMCDIR)/pmc_*.h" \
 "$(PMCDIR)/*_group.h" \
 "$(PMCDIR)/*$(LOAD_EXT)" \
 "$(PMCDIR)/*.dump" \
 "$(PMCDIR)/*.c" \
 "$(PMCDIR)/*$(O)" \
 "$(PMCDIR)/*.def" \
 "$(PMCDIR)/*.exp" \
 "$(PMCDIR)/*.pdb" \
 "$(PMCDIR)/*.ilk" \
 "$(PMCDIR)/*.lib" \
 "$(OPSDIR)/*.c" \
 "$(OPSDIR)/*.h" \
 "$(OPSDIR)/*$(O)" \
 "$(OPSDIR)/*$(LOAD_EXT)" \
 "$(OPSDIR)/*.exp" \
 "$(OPSDIR)/*.pdb" \
 "$(OPSDIR)/*.ilk" \
 "$(OPSDIR)/*.lib" \
 "*.pbc" \
 "*.dll" \
 "src/*.pbc" \
 src/it.pir \
 src/builtins.pir \
 class2pbc$(EXE) installable_class2pbc$(EXE)

clean:
	$(RM_F) $(CLEANERS)

realclean : clean
	$(RM_F) Makefile config/J2PConfig.pm "*~" "*/*~"
