#
# Makefile for Duplicacy Sandbox
#

DUPLICACY=duplicacy

default: build


#
# Construction / Destruction
#

STORAGE=storage
$(STORAGE):
	mkdir -p $@
TO_CLEAN += $(STORAGE)


ROOT=root
$(ROOT): $(STORAGE)
	mkdir -p $@
	if [ ! -e "$@/.duplicacy" ] ; \
	then \
	    cd $@ && $(DUPLICACY) init sandbox $(shell cd $(STORAGE) && pwd) ; \
	fi
TO_CLEAN += $(ROOT)



build: $(ROOT)


# Populate the root with some files, revise them and make backups
# after each step.
populate: build
	for REVISION in 1 2 3 4 5 ; \
	do \
	    for FILE in 1 2 3 4 5 ; \
	    do \
	        echo "This is file $$FILE, revision $$REVISION" \
	            >> "$(ROOT)/file$$FILE" ; \
	    done ; \
	    $(MAKE) backup ; \
	done

clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -rf



#
# Duplicacy Operations
#

# Run a backup
backup: build
	cd $(ROOT) && $(DUPLICACY) -v backup -stats

# List all revisions and files
files: build
	cd $(ROOT) && $(DUPLICACY) -v list -files

# List all revisions
list: build
	cd $(ROOT) && $(DUPLICACY) -v list

# Do an exhaustive pruning
prune: build
	cd $(ROOT) && $(DUPLICACY) -v prune -exhaustive
