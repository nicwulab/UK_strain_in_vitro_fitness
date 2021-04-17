# only PROJECT_PATH variable and reference needed to change
PROJECT_PATH=config['PROJECTPATH'] #'/Users/yiquan/PycharmProjects/SARS-CoV-2/SARS-Competition'


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import glob
import os
import numpy as np
plt.rc('axes', labelsize=15)
plt.rc('xtick', labelsize=15)
plt.rc('ytick', labelsize=15)

MBCS_region = PROJECT_PATH + '/ref/UK_MBCS_region.bed'
REF = PROJECT_PATH + '/ref/Bavtpat1_complete.fa'
#PRIMERS = PROJECT_PATH + '/ref/primers.txt'
R1 = PROJECT_PATH + '/data/{SAMPLENAME}_L001_R1_001.fastq.gz'
R2 = PROJECT_PATH + '/data/{SAMPLENAME}_L001_R2_001.fastq.gz'
SAMPLENAMES, = glob_wildcards(R1)
RESULT_PATH = PROJECT_PATH + '/results/{SAMPLENAME}'
TRIMMED_FQ = RESULT_PATH + '/trimmed.fq.gz'
MERGED_FQ = RESULT_PATH + '/merged.fq.gz'
BAM = RESULT_PATH + '/aligned.bam'
TRIMMED_BAM = RESULT_PATH + '/trimmed.bam'
SORTED_BAM = RESULT_PATH + '/sorted.bam'
FILTER_SORTED_BAM = RESULT_PATH + '/filter_sorted.bam'
DEPTH_FILE = RESULT_PATH + '/coverage.per-base.bed.gz'
SNP_FILE = RESULT_PATH + '/variants.snp'
SEQ_LOGO = RESULT_PATH + '/MBCS_seqlogo.png'
FREQ_FILE = RESULT_PATH + '/MBCS_freq.tsv'
COVERAGE_PNG_PER_SAMPLE = RESULT_PATH + '/coverage.pdf'

rule all:
    input:
        expand(SNP_FILE, SAMPLENAME = SAMPLENAMES),
        expand(FILTER_SORTED_BAM, SAMPLENAME = SAMPLENAMES),
        expand(SEQ_LOGO, SAMPLENAME = SAMPLENAMES),
        expand(FREQ_FILE, SAMPLENAME = SAMPLENAMES),
        expand(COVERAGE_PNG_PER_SAMPLE, SAMPLENAME = SAMPLENAMES)

rule plotDepth_per_sample:
    input:
        DEPTH_FILE

    output:
        COVERAGE_PNG_PER_SAMPLE

    shell:
        'python coverage_plot.py {input} {output}'


rule cal_depth:
    input:
        FILTER_SORTED_BAM

    params:
        PREFIX = RESULT_PATH + '/coverage',
        REF = MBCS_region

    output:
        DEPTH_FILE

    shell:
        'mosdepth --by {params.REF} {params.PREFIX} {input}'


rule cal_frequency:
    input:
        FILTER_SORTED_BAM

    output:
        SEQ_LOGO = SEQ_LOGO,
        FREQ_FILE = FREQ_FILE

    shell:
        'python extract_MBCS.py {input} {output.FREQ_FILE} {output.SEQ_LOGO}'


rule variant_calling_with_varscan:
    input:
        FILTER_SORTED_BAM

    params:
        REF_FA = REF

    output:
        SNP_FILE

    shell:
        'samtools mpileup --excl-flags 2048 --excl-flags 256  '\
        '--fasta-ref {params.REF_FA} '\
        '--max-depth 50000 --min-MQ 30 --min-BQ 30  {input} '\
        '| varscan pileup2cns '\
        ' --min-coverage 10 ' \
        ' --min-reads2 2 '\
        '--min-var-freq 0.01 '\
        '--min-freq-for-hom 0.75 '
        '--p-value 0.05 --variants 1 ' \
        '> {output}'

rule sort_bam_with_samtools:
    input:
        TRIMMED_BAM

    output:
        SORTED_BAM

    shell:
        'samtools sort {input} > {output};'\
        ' samtools index {output}'

rule filter_sorted_bam:
    input:
        SORTED_BAM

    params:
        SIZE=200

    output:
        FILTER_SORTED_BAM

    shell:
        'samtools view -h {input}' \
        "| gawk '$1~/^\@/ || ($9 > {params.SIZE} || $9 < -{params.SIZE})'" \
        '|samtools view -b' \
        '> {output};'\
        ' samtools index {output}'

rule trim_primers_from_alignment_with_bamutils:
    input:
        BAM

    params:
        REF_FA = REF


    output:
        TRIMMED_BAM

    shell:
        'bam trimbam {input} - -L 30 -R 0 --clip '\
        '| samtools fixmate - - '\
        '| samtools calmd -Q - {params.REF_FA} '\
        '> {output} '


rule align_with_bowtie:
    input:
        TRIMMED_FQ

    params:
        REF = REF

    output:
        BAM

    shell:
        'bowtie2 -x {params.REF} '\
        '--no-discordant --dovetail --no-mixed --maxins 2000 ' \
        '--interleaved {input} --mm '\
        '| samtools view -bF 4  > {output}'

rule trim_adapter_with_cutadapt:
    input:
        FQ1 = R1,
        FQ2 = R2

    output:
        TRIMMED_FQ

    shell:
        'seqtk mergepe {input.FQ1} {input.FQ2} '\
        '| cutadapt -B AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTG '\
        '-b AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC '\
        '--interleaved --minimum-length 50 '\
        '-o {output} -'
