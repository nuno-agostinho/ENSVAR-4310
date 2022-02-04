#!/bin/sh
#BSUB -J test-data

dir=input/annotation
testDir=testdata

prepareTestData () {
  pattern=$1
  file=$2
  out=$3
  grep $pattern $file > $out
  ./scripts/prepare-input.sh $out
}

# create test data from chromosome 21 or mithocondrial
prepareTestData "^21" $dir/ensembl.annotation.gff3 $testDir/test_new.gff3
prepareTestData "^21" $dir/ensembl.annotation.gtf $testDir/test_new.gtf
prepareTestData "^MT" $dir/ensembl.annotation.gtf $testDir/test_MT_new.gtf
