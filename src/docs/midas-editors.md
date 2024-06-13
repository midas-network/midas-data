# MIDAS Editors Documentation

## Editors workflow

1. There are two places where the MIDAS ontology can be updated:
   1. [src/ontology/midas-data-edit.owl](https://github.com/midas-network/midas-data/blob/main/src/ontology/midas-data-edit.owl). This file is manually edited, for example with [Protege](https://protege.stanford.edu/).
   1. [The Apollo SV import file](https://github.com/midas-network/midas-data/blob/main/src/ontology/imports/seed.txt). If you want to import a term from the Apollo SV vocabulary ([github](https://github.com/ApolloDev/apollo-sv), [OLS](https://www.ebi.ac.uk/ols4/ontologies/apollo_sv)), you simply add it to this file.
1. After the editor performed their edit, they usually create a pull request and have it reviewed by another editor.
1. Once the pull request is merged, the [automated GitHub Action](https://github.com/midas-network/midas-data/blob/main/.github/workflows/release.yml) of the Midas Ontology is triggered. This will rebuild the ontology, and its imports automatically.  The resulting ontology file will be written at the top level of this GitHub repository.
1. The update of the ontology will also result in a [tagged release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository), see for example [this release](https://github.com/midas-network/midas-data/releases/tag/v2023-06-09). _NOTE_: There can be only _one release per day_. If you make more than one edits within a single day, subsequent edits will not result in a new release, and you will have to trigger another release at a future date. All your edits are of course preserved.
1. Even without performing an edit, you can manually run a release by going to the [GitHub Actions Tab](https://github.com/midas-network/midas-data/actions/workflows/release.yml) and clicking on the "Run workflow" button on the right. Make sure the `main` branch is selected, and click `Run workflow` (green button) again. Currently, a full release takes about 90-100 seconds.
1. When a release has failed, you will receive an email. You can head, again, to the [GitHub Actions Tab](https://github.com/midas-network/midas-data/actions/workflows/release.yml) and click on the last failed run of the action (red X). You then click on the failed task (for example, `build` or `Create Release`), and read through the documentation. The most likely reason of failure is that you tried to create a second release after you have already created one, but occassionally, there may be problems with the ontology (such as a logical inconsistency).

References: 
1. [Ontology Development Kit](https://incatools.github.io/ontology-development-kit/)
