GEM := mruby-simplehttp

include $(MAKEFILE_4_GEM)

CFLAGS += -I$(MRUBY_ROOT)/include
MRUBY_CFLAGS += -I$(MRUBY_ROOT)/include

GEM_RB_FILES := $(wildcard $(MRB_DIR)/*.rb)

gem-all : gem-rb-files

gem-clean : gem-clean-rb-files
