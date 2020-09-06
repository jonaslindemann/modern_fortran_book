# http://lackof.org/taggart/hacking/make-example/

SUBDIRS = src

BUILDDIRS = $(SUBDIRS:%=build-%)
CLEANDIRS = $(SUBDIRS:%=clean-%)

all: $(BUILDDIRS)

$(BUILDDIRS):
	 $(MAKE) -C $(@:build-%=%)

clean: $(CLEANDIRS)

$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean
	
.PHONY: subdirs $(CLEANDIRS)	
.PHONY: clean