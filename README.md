# ENSVAR-4310: test VEP with new GTF/GFF3 annotation files

This projects tests different annotation formats to check if they are all supported by VEP.

## How to run the script in LSF

Install [Nextflow](https://nextflow.io) and run:

```
bsub -M 4000 nextflow run main.nf
```

VEP output files and logs are saved in folder `output`.
