# Midas Ontology Makefile
# Bill Hogan <hoganwr@ufl.edu>
# edit 2025-05-27, John Levander <jdl50@pitt.edu>
# edit 2025-07-23 - add NCIT ontology import, Lucie Contamin <contamin@pitt.edu)
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

# give Robot a 4 gig heap
ROBOT := java -Xmx12G -jar build/robot.jar

SRC = midas-data-edit.owl
RELEASE_ASSETS = midas-data.owl
RELEASEDIR = ../..
MIRRORDIR = mirror
IMPORTDIR = imports
ANNOTATION_PROPERTIES = IAO:0000115 rdfs:label  dc:creator dc:date IAO:0000111 IAO:0000112 IAO:0000117 rdfs:comment IAO:0000118 IAO:0000412 IAO:0000600 http://purl.obolibrary.org/obo/apollo_sv.owl/APOLLO_SV_0000040
IMPORTS = $(IMPORTDIR)/apollo-sv_import.owl $(IMPORTDIR)/ncbitaxon_import.owl $(IMPORTDIR)/mondo_import.owl $(IMPORTDIR)/ncit_import.owl
MIRRORS = $(MIRRORDIR)/apollo-sv.owl $(MIRRORDIR)/ncbitaxon.owl $(MIRRORDIR)/mondo.owl $(MIRRORDIR)/ncit.owl

########################### Helper Functions ##################################
# "mirror_ontology" is a helper function to download and convert ontologies
# $(1) = ontology name (e.g., apollo-sv)
# $(2) = ontology source path (e.g., apollo_sv.owl)
define mirror_ontology
$(MIRRORDIR)/$(1).owl: | build/robot.jar
	mkdir -p $(MIRRORDIR)
	$(ROBOT) convert -I $(OBO)/$(2) -o $$@
endef

# "create_import" is a helper function to create imports for ontologies
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
########################### End Helper Functions ##############################

.PHONY: clean
clean:
	@echo "-- Cleaning up build artifacts --"
	rm -f midas-data.owl
	rm -f $(MIRRORDIR)/*.owl
	rm -f $(MIRRORDIR)/*.zip
	rm -f $(IMPORTDIR)/*.owl

.PHONY: create_imports
create_imports: $(IMPORTS)
	@echo "-- Creating imports in $(IMPORTDIR) --"
	mkdir -p $(IMPORTDIR)
	@echo "Seed file for imports $(IMPORTDIR)/seed.txt"
	@echo "This file is used to create imports for the ontologies. $(IMPORTDIR)/seed.txt"
	@echo "You can add terms to this file to include them in the imports.  $(IMPORTDIR)/seed.txt"
	@echo "You can also remove terms from this file to exclude them from the imports. $(IMPORTDIR)/seed.txt"
# Download and mirror the ontologies
$(eval $(call mirror_ontology,apollo-sv,apollo_sv.owl))
$(eval $(call mirror_ontology,ncbitaxon,ncbitaxon/subsets/taxslim.owl))
$(eval $(call mirror_ontology,mondo,mondo/mondo-simple.owl))
$(eval $(call mirror_ontology,ncit,ncit.owl))

# Create the imports
$(eval $(call create_import,mondo,http://purl.obolibrary.org/obo/MONDO_,false))
$(eval $(call create_import,apollo-sv,http://purl.obolibrary.org/obo/APOLLO_SV_,true))
$(eval $(call create_import,ncbitaxon,http://purl.obolibrary.org/obo/NCBITaxon_,true))
$(eval $(call create_import,ncit,http://purl.obolibrary.org/obo/NCIT_,true))

midas-data.owl: $(SRC) $(IMPORTS) $(MIRRORS) | build/robot.jar
	@echo "-- Creating MIDAS data ontology in $(realpath .) --"
	$(ROBOT) merge --input $< $(patsubst %, --input %, $(IMPORTS)) \
	reason --reasoner HermiT --equivalent-classes-allowed none \
	annotate \
	--ontology-iri "$(MIDAS)/midas-data.owl" \
	--version-iri "$(MIDAS)/v$(TODAY)/midas-data.owl" \
	--annotation owl:versionInfo "$(TODAY)" \
	--output $@

.PHONY: zip_ontologies
zip_ontologies: $(MIRRORDIR)/apollo-sv.owl $(MIRRORDIR)/mondo.owl $(MIRRORDIR)/ncbitaxon.owl $(IMPORTS) midas-data.owl #$(MIRRORDIR)/ncit.owl
	@echo "-- Zipping all ontologies in $(MIRRORDIR) and $(IMPORTDIR) --"
	for f in mirror/*.owl; do zip -j "$(basename "$$f".owl).zip" "$$f"; done
	@echo "Zipped ontologies in $(MIRRORDIR) to $(MIRRORDIR).zip"
	for f in imports/*.owl; do zip -j "$(basename "$$f".owl).zip" "$$f"; done
	@echo "Zipped all ontologies in $(IMPORTDIR) to $(IMPORTDIR).zip"

.PHONY: delete_owl_files
delete_owl_files: $(MIRRORDIR)/apollo-sv.owl $(MIRRORDIR)/mondo.owl $(MIRRORDIR)/ncbitaxon.owl $(IMPORTS) midas-data.owl #$(MIRRORDIR)/ncit.owl
	@echo "-- Deleting all owl files in $(MIRRORDIR) and $(IMPORTDIR) --"
	rm -f $(MIRRORDIR)/*.owl
	@echo "Deleted all owl files in $(MIRRORDIR)"
	rm -f $(IMPORTDIR)/*.owl
	@echo "Deleted all owl files in $(IMPORTDIR)"


.PHONY: prepare_release
prepare_release: $(RELEASE_ASSETS) midas-data.owl
	@echo "-- Preparing release files in $$(realpath $(RELEASEDIR)) --"
	rsync -R $(RELEASE_ASSETS) $(RELEASEDIR)
	@echo "Release files are now in $$(realpath $(RELEASEDIR)) - now you should commit, push and make a release \n on your git hosting site such as GitHub or GitLab"

all: clean create_imports zip_ontologies delete_owl_files prepare_release
