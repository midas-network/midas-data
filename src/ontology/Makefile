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

all: midas-data.owl

$(MIRRORDIR)/apollo-sv.owl: | build/robot.jar
	mkdir -p $(MIRRORDIR)
	$(ROBOT) convert -I $(OBO)/apollo_sv.owl -o $@

$(IMPORTDIR)/apollo-sv_import.owl: $(MIRRORDIR)/apollo-sv.owl $(IMPORTDIR)/seed.txt | build/robot.jar
	$(ROBOT) \
		extract -vv -i $< -T $(IMPORTDIR)/seed.txt --copy-ontology-annotations true --force true --method subset \
    	remove --base-iri http://purl.obolibrary.org/obo/APOLLO_SV_ --axioms external --preserve-structure false --trim false \
		remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/seed.txt --select complement \
		annotate --ontology-iri "$(MIDAS)/$@" --output $@

$(MIRRORDIR)/ncbitaxon.owl: | build/robot.jar
	mkdir -p $(MIRRORDIR)
	$(ROBOT) convert -I $(OBO)/ncbitaxon/subsets/taxslim.owl -o $@

$(IMPORTDIR)/ncbitaxon_import.owl: $(MIRRORDIR)/ncbitaxon.owl $(IMPORTDIR)/seed.txt | build/robot.jar
	$(ROBOT) \
		extract -i $< -T $(IMPORTDIR)/seed.txt --copy-ontology-annotations true --force true --method subset \
	remove --base-iri http://purl.obolibrary.org/obo/NCBITaxon_ --axioms external --preserve-structure false --trim false \
		remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/seed.txt --select complement \
	annotate --ontology-iri "$(MIDAS)/$@" --output $@

$(MIRRORDIR)/mondo.owl: | build/robot.jar
	mkdir -p $(MIRRORDIR)
	$(ROBOT) convert -I $(OBO)/mondo/subsets/mondo.owl -o $@
	
$(IMPORTDIR)/mondo_import.owl: $(MIRRORDIR)/mondo.owl $(IMPORTDIR)/seed.txt | build/robot.jar
	$(ROBOT) \
		extract -i $< -T $(IMPORTDIR)/seed.txt --copy-ontology-annotations true --force true --method subset \
	remove --base-iri http://purl.obolibrary.org/obo/MONDO_ --axioms external --preserve-structure false --trim false --output $@\
	remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/seed.txt --select complement \
	annotate --ontology-iri "$(MIDAS)/$@" --output $@

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
	rsync -R $(RELEASE_ASSETS) $(RELEASEDIR)
	echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release \
        on your git hosting site such as GitHub or GitLab"
