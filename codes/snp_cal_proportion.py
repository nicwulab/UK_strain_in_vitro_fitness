import glob
import pandas as pd
import os

def merge_snp(in_files_path, out_files_path):
    snp_files = glob.glob(in_files_path)
    out_filename = out_files_path
    print("writing %s" % out_filename)
    outfile = open(out_filename, 'w')
    header = 1
    for snp_file in sorted(snp_files, key=lambda x: int(os.path.basename(os.path.dirname(x)).rsplit('_')[0])):
        sampleID = os.path.basename(os.path.dirname(snp_file)).rsplit('_')[0]
        infile = open(snp_file, 'r')
        for line in infile.readlines():
            if "Chrom" in line and header == 1:
                outfile.write("Sample" + "\t" + line)
                header = 0
            elif "Chrom" in line and header == 0:
                continue
            else:
                outfile.write(sampleID + "\t" + line)
        infile.close()
    return outfile

def merge_coverage(in_files_path, out_files_path):
    MBCS_coverage_files = glob.glob(in_files_path)
    out_filename = out_files_path
    print("writing %s" % out_filename)
    coverage_df = pd.DataFrame()
    for coverage_file in sorted(MBCS_coverage_files, key=lambda x: int(os.path.basename(os.path.dirname(x)).rsplit('_')[0])):
        sampleID = os.path.basename(os.path.dirname(coverage_file)).rsplit('_')[0]

        infile = pd.read_csv(coverage_file,names=["chrom", "start", "end", "read_coverage"], sep="\t").assign(samplename=sampleID)
        coverage_df= pd.concat([coverage_df,infile],axis=0)
    outfile = coverage_df.to_csv(out_filename)

    return outfile
### merge MBCS coverage

#merge_coverage("results/UK_adapted/*/coverage.regions.bed.gz", "results/UK_adapted/all_MBCS_coverage.csv")

### merge_snp###

merge_snp("results/UK_adapted/*/variants.snp", "results/UK_adapted/all_variants.snp")


### calculate the proportion of UK strain###

#snpfiles = pd.read_csv("results/all_variants.snp", sep='\t')
#UK_marker = [913,1643,3267,5388,5986,6730,6954,11287,12312,14125,14408,14676,15279,16176,23063,23271,23604,23709,24506,24914,27972,28048,28095,28111,28253,28270,28280,28281,28282,28881,28882,28883,28977]
#marker_pos_df = snpfiles[snpfiles.Position.isin(UK_marker)]
#marker_pos_df.to_csv("results/UK_marker_position.csv")

#uk_proportion_df= marker_pos_df[["Sample","VarFreq"]]
#convert_dict = {'Sample': int,
#                'VarFreq': float
#               }
#uk_proportion_df["VarFreq"] =[x[:-1] for x in uk_proportion_df['VarFreq']]
#uk_proportion_df = uk_proportion_df.astype(convert_dict).groupby(by=["Sample"]).mean()
#uk_proportion_df.to_csv("results/UK_proportion2.csv")
