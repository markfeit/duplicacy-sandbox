#
# Makefile for Duplicacy Sandbox
#

# Configure the following to taste:

# Name of duplicacy program to run
DUPLICACY:=$(shell pwd -P)/duplicacy

# Names of additional storage directories
# EXTRA_STORAGE=secondary

# Number of revisions to create
REVS=5


# Number of revisions to create
FILES=5


# End of configurables

# These are a POSIX-compatible alternative to seq(1)
REVS_SEQ:=$(shell awk -v SEQEND=$(REVS) 'BEGIN { for(i=1;i<=SEQEND;i++) print i }')
FILES_SEQ:=$(shell awk -v SEQEND=$(FILES) 'BEGIN { for(i=1;i<=SEQEND;i++) print i }')



default: build


#
# Construction / Destruction
#

STORAGE_NAMES=default $(EXTRA_STORAGE)

STORAGE_DIR=storage
STORAGES=$(STORAGE_NAMES:%=$(STORAGE_DIR)/%)
$(STORAGES):
	mkdir -p $@
TO_CLEAN += $(STORAGE_DIR)


ROOT=root
$(ROOT): $(STORAGES)
	mkdir -p $@
	@if [ ! -e "$@/.duplicacy" ] ; \
	then \
	    for STORAGE in $(STORAGE_NAMES) ; \
	    do \
	        STORAGE_NAME="$(STORAGE_DIR)/$${STORAGE}" ; \
	        STORAGE_PATH=$$(cd "$${STORAGE_NAME}" && pwd) ; \
	        case $$STORAGE in \
	          *default) \
	            ( cd $@ && $(DUPLICACY) init sandbox "$${STORAGE_PATH}" ) \
	            ;; \
	          *) \
	            ( cd $@ && $(DUPLICACY) add "$${STORAGE}" \
	                sandbox "$${STORAGE_PATH}" ) \
	            ;; \
	        esac ; \
	    done ; \
	fi
TO_CLEAN += $(ROOT)



build: $(ROOT)


# Populate the root with some files, revise them and make backups
# after each step.
populate: build
	for REVISION in $(REVS_SEQ) ; \
	do \
	    for FILE in $(FILES_SEQ) ; \
	    do \
	        echo "This is file $$FILE, revision $$REVISION" \
	            "at $$(date)" \
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
	@for STORAGE in $(STORAGE_NAMES) ; \
	do \
	    printf "\n#\n# Backing up to $$STORAGE\n#\n\n" ; \
	    ( cd $(ROOT) && $(DUPLICACY) -v backup -stats \
	        -storage "$${STORAGE}" ) ; \
	done

# List all revisions and files
files: build
	@for STORAGE in $(STORAGE_NAMES) ; \
	do \
	    printf "\n#\n# Files in $$STORAGE\n#\n\n" ; \
	    ( cd $(ROOT) && $(DUPLICACY) -v list -files ) ; \
	done

# List all revisions
list: build
	@for STORAGE in $(STORAGE_NAMES) ; \
	do \
	    printf "\n#\n# Revisions in $$STORAGE\n#\n\n" ; \
	    ( cd $(ROOT) && $(DUPLICACY) -v list ) ; \
	done


# Do an exhaustive pruning
prune: build
	@for STORAGE in $(STORAGE_NAMES) ; \
	do \
	    printf "\n#\n# Pruning $$STORAGE\n#\n\n" ; \
	    ( cd $(ROOT) && $(DUPLICACY) -v prune -exhaustive ) ; \
	done


# Remove the first revision, make a backup and then prune.
chop: build
	( cd $(ROOT) && $(DUPLICACY) -v list ) \
	| egrep -e 'revision [0-9]+ created' \
	| sed -e 's/^.*revision \([0-9]\+\).*$$/\1/' \
	| head -1 \
	| ( cd $(ROOT) && xargs -n 1 $(DUPLICACY) -v prune -r )
	$(MAKE) backup
	$(MAKE) prune
