ifeq "$(strip ${BUILD_DIR})" ""
  BUILD_DIR    := ../$(OSTYPE)-$(MACHINETYPE)/obj
endif
ifeq "$(strip ${TARGET_DIR})" ""
  TARGET_DIR   := ../$(OSTYPE)-$(MACHINETYPE)/bin
endif

TARGET   := mecat2cns_gpu 
TGT_LINKER := nvcc 

SRC_CXXFLAGS := -pthread -D_GLIBCXX_PARALLEL -fopenmp

SOURCES  := main.cpp \
	argument.cpp \
	dw.cu \
	MECAT_AlnGraphBoost.C \
	mecat_correction.cpp \
	options.cpp \
	overlaps_partition.cpp \
	reads_correction_aux.cpp \
	reads_correction_can.cpp \
	reads_correction_m4.cpp \

SRC_INCDIRS  := . libboost

TGT_LDFLAGS := -L${TARGET_DIR} -Xcompiler="-pthread" -lm -Xcompiler="-fopenmp"
TGT_LDLIBS  := -lmecat
TGT_PREREQS := libmecat.a

SUBMAKEFILES :=
