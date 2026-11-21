# Local patch applied while building the MONDO import (imports/mondo_import.owl).
# Used by src/ontology/Makefile (create_import macro, 4th argument).
#
# Problem: MONDO classifies listeriosis (MONDO:0005828) as a subclass of
# vector-borne disease (MONDO:0100120). Listeriosis is foodborne; it is not
# transmitted by a vector organism.
#
# Reported to MONDO: <add GitHub issue URL here>
#
# Remove this patch once MONDO has fixed the classification. Until then it is
# safe to keep: if the statement is no longer present, the update does nothing.

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo:  <http://purl.obolibrary.org/obo/>

DELETE DATA {
  obo:MONDO_0005828 rdfs:subClassOf obo:MONDO_0100120 .
}
