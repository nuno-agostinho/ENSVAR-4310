#!/bin/sh
#BSUB -J vep-gff3
#BSUB -o logs/vep-gff3-%J.out

# Create directories if they do not exist: output and logs
mkdir -p output2 logs

# Params
dataDir=/nfs/production/flicek/ensembl/variation/data
cacheDir=$dataDir/VEP/
fasta=$dataDir/Homo_sapiens.GRCh38.dna.toplevel.fa.gz

vepDir=/hps/software/users/ensembl/repositories/nuno/ensembl-vep
vep=$vepDir/vep
vcf=$vepDir/examples/homo_sapiens_GRCh38.vcf

# Functions
vep_run () {
    assembly=GRCh38
    echo " -> Running VEP with $annot (perl$perlVersion, $type, $assembly, $format)"
    plenv local $perlVersion

    input=$(basename $annot)
    perl $vep --i $vcf \
              --o output2/${LSB_JOBNAME}-${LSB_JOBID}.$perlVersion.$type.$input.$assembly.$format \
              --$format \
              --assembly $assembly \
              --force_overwrite \
              --fasta $fasta \
              $@
}

vep_cache () {
    type=cache
    vep_run --cache \
            --dir_cache $cacheDir \
            --cache_version 102 \
            --offline \
            $@
}

vep_database () {
    type=database
    vep_run --database \
            $@
}

#vcf=NA12878.vcf.gz
for run in vep_cache vep_database; do
    for perlVersion in 5.14.4 5.26.2; do
        for format in json tab vcf; do
            for annot in input/annotation/*gz; do
                ext=${annot%.*}
                ext=$(echo "${ext##*.}" | grep -Po "[A-Za-z]+")
                $run --$ext $annot
            done
        done
    done
done

#perlVersion=5.14.4
#format=tab
#vep_cache
