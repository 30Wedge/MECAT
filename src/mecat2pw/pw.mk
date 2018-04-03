ifeq "$(strip ${BUILD_DIR})" ""
  BUILD_DIR    := ../$(OSTYPE)-$(MACHINETYPE)/obj
endif
ifeq "$(strip ${TARGET_DIR})" ""
  TARGET_DIR   := ../$(OSTYPE)-$(MACHINETYPE)/bin
endif

TARGET   := mecat2pw
SOURCES  := pw.cpp pw_impl.cpp pw_options.cpp

SRC_CXXFLAGS := -pthread -D_GLIBCXX_PARALLEL -fopenmp 
SRC_INCDIRS  := ../common .

TGT_LDFLAGS := -L${TARGET_DIR} -pthread -fopenmp
TGT_LDLIBS  := -lmecat
TGT_PREREQS := libmecat.a

SUBMAKEFILES :=
