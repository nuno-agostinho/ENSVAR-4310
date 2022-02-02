#!/usr/bin/env nextflow
// Validate new Ensembl GFF3/GTF files
nextflow.enable.dsl=2

params.perl     = Channel.from( "5.14.4", "5.26.2" ).first()
params.format   = Channel.from( "tab", "json", "vcf" )

params.vep      = "/hps/software/users/ensembl/repositories/nuno/ensembl-vep/vep"
params.cacheDir = "/nfs/production/flicek/ensembl/variation/data/VEP"
params.fasta    = "/nfs/production/flicek/ensembl/variation/data/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
params.vcf      = "/nfs/production/flicek/ensembl/variation/data/PlatinumGenomes/NA12878.vcf.gz"
params.annot    = Channel.fromPath( "input/annotation/*.gz" )

// to pass flags in CLI besides the ones used as baseline, use double quotes
// and add a space somewhere inside the string
//   e.g. nextflow run main.nf --flags "--regulatory "
params.flags     = null 

process vep {
    tag "$perlVersion $annot.baseName $type"
    publishDir 'output'

    time '6h'
    memory { 8.GB * task.attempt }
    errorStrategy 'retry'

    input:
        val perlVersion
        path vep
        each format
        path vcf
        path fasta
        path cacheDir
        each annot
        val type
    output:
        file '*'
    """
    plenv local $perlVersion

    ext=${annot}
    ext=\${ext%.*}
    ext=\$(echo \${ext##*.} | grep -Po "[A-Za-z]+")

    if [[ "${type}" = "database" ]]; then
        args="--database"
    else
        args="--cache --dir_cache ${cacheDir} --cache_version 102 --offline"
    fi

    name=vep-\$( echo "${perlVersion} ${annot.baseName} ${type}" | sed 's/-//g' | sed 's/ /-/g' )
    name=\${name}-\${LSB_JOBID}
    perl ${vep} \
         --i $vcf \
         --o \${name}.txt \
         --assembly GRCh38 \
         --fasta $fasta \
         --\${ext} ${annot} \
         \${args} > \${name}.out 2>&1
    """
}

workflow {
    type = Channel.from( "cache", "database" )
    vep( params.perl, params.vep, params.format, params.vcf, params.fasta,
         params.cacheDir, params.annot, type )
}

// Print summary
workflow.onComplete {
    println ( workflow.success ? """
        Workflow summary
        ----------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}
