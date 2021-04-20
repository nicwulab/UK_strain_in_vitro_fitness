# UK strain competition  #

TODO: Proejct detail goes here

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
