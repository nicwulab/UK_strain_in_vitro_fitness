# UK strain competition  #

[![test pipeline](https://github.com/nicwulab/UK_strain_in_vitro_fitness/actions/workflows/test_env.yml/badge.svg)](https://github.com/nicwulab/UK_strain_in_vitro_fitness/actions/workflows/test_env.yml)

This project describes the analysis for the next-generation sequencing data in this study: [Human organoid systems reveal in vitro correlates of fitness for SARS-CoV-2 B.1.1.7](https://www.biorxiv.org/content/10.1101/2021.05.03.441080v1). Raw sequencing data can be found in [BioProject PRJNA722947](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA722947).

## Create working environment ##

Pre-requisites, using [conda](https://docs.conda.io/en/latest/miniconda.html) to create the working environment:

```
conda env create -f env.yml
```

## Data ##

All paired-end fastq files (naming as ```*_L001_R1.fastq.gz``` and ```*L001_R2.fastq.gz```) go into the folder ```data```


## Analysis ##

Running the pipeline:

```
cd codes
conda activate UK_sars
snakemake -s pipeline.smk -p  --config PROJECTPATH=$(dirname $(pwd))
```
