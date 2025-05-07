# Midas Ontology Makefile
# Bill Hogan <hoganwr@ufl.edu>
#
# This Makefile is used to build artifacts
# for the Ontology for Biomedical Investigations.
#
# WARN: This file contains significant whitespace, i.e. tabs!
# Ensure that your text editor shows you those characters.

### Configuration
#
# These are standard options to make Make sane:
# <http://clarkgrubb.com/makefile-style-guide#toc2>

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

### Definitions

OBO     := http://purl.obolibrary.org/obo
MIDAS	:= http://midasnetwork.us/datasets
TODAY   := $(shell date +%Y-%m-%d)

### Release files

# We use the official development version of ROBOT for most things.
build/robot.jar:
	mkdir -p build
	curl -L -o $@ https://github.com/ontodev/robot/releases/download/v1.9.4/robot.jar

ROBOT := java -jar build/robot.jar

SRC = midas-data-edit.owl
RELEASE_ASSETS = midas-data.owl
RELEASEDIR = ../..
MIRRORDIR = mirror
IMPORTDIR = imports
ANNOTATION_PROPERTIES = rdfs:label IAO:0000115 dc:creator dc:date IAO:0000111 IAO:0000112 IAO:0000117 rdfs:comment IAO:0000118 IAO:0000412 IAO:0000600 http://purl.obolibrary.org/obo/apollo_sv.owl/APOLLO_SV_0000040
IMPORTS = $(IMPORTDIR)/apollo-sv_import.owl $(IMPORTDIR)/ncbitaxon_import.owl $(IMPORTDIR)/mondo_import.owl

.PHONY: clean
clean:
	rm -f midas-data.owl
	rm -f $(MIRRORDIR).owl
	rm -f $(MIRRORDIR).zip

all: clean midas-data.owl prepare_release



# Define a function for mirroring ontologies
# $(1) = ontology name (e.g., apollo-sv)
# $(2) = ontology source path (e.g., apollo_sv.owl)
define mirror_ontology
$(MIRRORDIR)/$(1).owl: | build/robot.jar
	mkdir -p $(MIRRORDIR)
	$(ROBOT) convert -I $(OBO)/$(2) -o $$@
endef

# Define a function for creating ontology imports
# $(1) = ontology name (e.g., mondo)
# $(2) = base IRI for removal (e.g., http://purl.obolibrary.org/obo/MONDO_)
# $(3) = copy ontology annotations (true/false)
define create_import
$(IMPORTDIR)/$(1)_import.owl: $(MIRRORDIR)/$(1).owl $(IMPORTDIR)/seed.txt | build/robot.jar
	$(ROBOT) \
		extract -i $(MIRRORDIR)/$(1).owl -T $(IMPORTDIR)/seed.txt --copy-ontology-annotations $(3) --force true --method subset \
		remove --base-iri $(2) --axioms external --preserve-structure false --trim false \
		remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/seed.txt --select complement \
		annotate --ontology-iri "$(MIDAS)/$$@" --output $$@
endef

# Define a function for zipping individual ontologies
# $(1) = ontology name (e.g., apollo-sv)
define zip_individual_ontology
.PHONY: zip_$(1)
zip_$(1): $(MIRRORDIR)/$(1).zip

$(MIRRORDIR)/$(1).zip: $(MIRRORDIR)/$(1).owl
	mkdir -p $(MIRRORDIR)
	cd $(MIRRORDIR) && zip -j $(1).zip $(1).owl
endef

# Download and mirror the ontologies
$(eval $(call mirror_ontology,apollo-sv,apollo_sv.owl))
$(eval $(call mirror_ontology,ncbitaxon,ncbitaxon/subsets/taxslim.owl))
$(eval $(call mirror_ontology,mondo,mondo/mondo-simple.owl))

# Create the imports
$(eval $(call create_import,mondo,http://purl.obolibrary.org/obo/MONDO_,false))
$(eval $(call create_import,apollo-sv,http://purl.obolibrary.org/obo/APOLLO_SV_,true))
$(eval $(call create_import,ncbitaxon,http://purl.obolibrary.org/obo/NCBITaxon_,true))

# Create the MIDAS data ontology
midas-data.owl: $(SRC) $(IMPORTS) | build/robot.jar
	$(ROBOT) merge --input $< \
		reason --reasoner HermiT --equivalent-classes-allowed none \
		annotate \
			--ontology-iri "$(MIDAS)/midas-data.owl" \
			--version-iri "$(MIDAS)/v$(TODAY)/midas-data.owl" \
			--annotation owl:versionInfo "$(TODAY)" \
			--output $@


.PHONY: prepare_release
prepare_release: $(RELEASE_ASSETS)
	@echo "Preparing release files in $(RELEASEDIR)"
	@echo "Zipping all ontologies in $(MIRRORDIR)"
	zip -r9 $(MIRRORDIR).zip $(MIRRORDIR)/*
	rm -f $(MIRRORDIR).owl
	@echo "Deleted all owl files in $(MIRRORDIR)"



	rsync -R $(RELEASE_ASSETS) $(RELEASEDIR)
	@echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release \
        on your git hosting site such as GitHub or GitLab"
