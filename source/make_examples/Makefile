# http://lackof.org/taggart/hacking/make-example/

SUBDIRS = explicit_rule int_makros modules multiple pattern_rules pattern_rules_mod_dep simple subdirs subdirs_install variables zip

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