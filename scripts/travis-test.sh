#!/bin/bash

set -eo pipefail -o nounset


export PATH=/anaconda/bin:$PATH
conda install htslib gsort


CONDA_ROOT=$(conda info --root)
rm -rf $CONDA_ROOT/conda-bld/*

#CHECK_DIR=$TMPDIR/builds.$$/
CHECK_DIR=$CONDA_ROOT/conda-bld/*
echo $CHECK_DIR
rm -rf $CHECK_DIR
mkdir -p $CHECK_DIR

## cleanup
rmbuild() {
	rm -rf $CHECK_DIR
}
trap rmbuild EXIT

## Test recipes using bioconda-utils (modified from https://github.com/bioconda/bioconda-recipes/blob/master/scripts/travis-run.sh)
## bioconda-utils build (biconda-utils/utils.py get_recipes only supports two levels of nesting. !!Checking if the bicondoa team can change this!!)
##  Therefore, in order to test all recieps we have to run each species/build seperately 
# Homo-sapien
bioconda-utils build recipes/Homo_sapiens/GRCh37/ config.yaml --loglevel debug 
#bioconda-utils build recipes/Homo_sapiens/hg19/ config.yaml 
#bioconda-utils build recipes/Homo_sapiens/hg38-noalt/ config.yaml 
#bioconda-utils build recipes/Homo_sapiens/hg38/ config.yaml 
# Mus_musculus
#bioconda-utils build recipes/Mus_musculus/mm10/ config.yaml 
# Canis_familiaris
#bioconda-utils build recipes/Canis_familiaris/canFam3/ config.yaml  

#ls /anaconda/conda-bld/noarch/

echo "############################################################"
echo "############################################################"
echo "Checked Dependencies"
echo "############################################################"
echo "############################################################"

for bz2 in $CHECK_DIR/*.bz2; do
	if [[ "$(basename $bz2)" == "repodata.json.bz2" ]]; then
        echo ">repodata.json.bze"
        continue
    fi
	if [[ "$(basename $bz2)" == "*.bz2" ]]; then
        echo ">*.bz2"
		continue
	fi

	echo "############################################################"
	echo "############################################################"
	echo "Checking recipe" $(basename $bz2)
	echo "############################################################"
	echo "############################################################"
    echo "UPLOAD"
    echo $bz2
	if [[ "$ANACONDA_GGD_TOKEN" == "" ]]; then
		echo "\n> WARNING:"
		echo '> $ANACONDA_GGD_TOKEN not set'
    else
	    anaconda upload --user ggd-alpha -t $ANACONDA_GGD_TOKEN $bz2
        echo "UPLOADED"
    fi

#	ggd check-recipe $bz2

	# upload
	set +o nounset
	#if [[ "$TRAVIS_BRANCH" == "master" && "$TRAVIS_PULL_REQUEST" == "false" ]]; then
	#if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
	if [[ "true" ]]; then
		if [[ "$ANACONDA_GGD_TOKEN" == "" ]]; then
			echo "\n> WARNING:"
			echo '> $ANACONDA_GGD_TOKEN not set'
		else
			anaconda -t $ANACONDA_GGD_TOKEN upload $bz2
            echo "DONE"
		fi
	fi
	set -o nounset

done
