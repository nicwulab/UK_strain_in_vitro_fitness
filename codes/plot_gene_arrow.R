# Title     : to plot genome organization of SARS-CoV-2
# Objective : TODO
# Created by: yiquan
# Created on: 12/5/20
library(ggplot2)
library(gggenes)
library(cowplot)
library(ggpubr)
library("gridExtra")
library(scales)
library(RColorBrewer)
library(readr)
library(tidyr)
library(reshape2)
library(stringr)
library(dplyr)
library(crayon)

CoVgenome <- data.frame(
 molecule = "",
 Genome = "",
 start = c(266,21563,25393,26245,26523,27202,27394,27894,28274,29558),
 end = c(21555,25384,26220,26472,27191,27387,27759,28259,29533,29674),
 gene = c("ORFab","Spike","ORF3a","E","M","ORF6","ORF7a","ORF8","N","ORF10")
)

classifying_mut_type <- function(Con){
  if (grepl('\\+',Con)){
    return ("insertion")
    }
  else if (grepl('\\-',Con)){
    return ("deletion")
    }
  else{
    return ("mismatch")
    }
  }

format_varfreq <- function(VarFreq){
  return (as.numeric(str_replace(VarFreq, '%', ''))/100)
  }

graph1 <- c('P0','P24','P13','P1')
graph2 <- c('P32','P31','P17','P26','P28','P29')
graph3 <- c('P1','P3','P5','P57','P7','P9','P11','P12')
graph4 <- c('P24','P27')
graph5 <- c('P24','P51','P27')
graph6 <- c('P24','P25','P26','P27','P28','P29','P30','P31','P51','P52','P53','P54','P55','P56','P57','P58')
plot1 <- c(16,17,18,19,20,21)
plot2 <- c(22,23,24,25,26,27)
plot3 <- c(28,29,30,31)
plot4 <- c(32,33,35,36)
graph <- plot2

snp_table <- read_tsv('results/all_variants.snp') %>%
               mutate(mut_type=mapply(classifying_mut_type, Cons)) %>%
               mutate(VarFreq=mapply(format_varfreq, VarFreq)) %>%
               mutate(Sample=factor(Sample, levels=unique(rev(Sample)))) %>%
               select(Sample, Position, Cons, mut_type, VarFreq)
# replace VarFreq <0.1 to 0
snp_table$VarFreq[snp_table$VarFreq < 0.1] <- 0
#give the subtable the same order as given
snp_subtable <- snp_table[snp_table$Sample %in% graph,]

#change sample to factor with sample order level so ggplot can plot them orderly
snp_subtable$Sample <-factor(snp_subtable$Sample, levels = rev(graph))
#write.csv(snp_subtable,"graph/genome_graph/graph.csv")

colorscale  <- brewer.pal(8,"Accent")
textsize <- 10
p <- ggplot(snp_subtable,aes(y=Sample,x=Position,color=mut_type)) +
  geom_point(aes(fill=mut_type,size=VarFreq),color='black',shape=21,stroke=0.5) +
  scale_size_continuous(range = c(-1,9),limits = c(0,1)) +
  scale_fill_manual(values=alpha(colorscale, 0.5)) +
  theme_cowplot(20) +
  theme(axis.title=element_text(size=textsize,face="bold"),
        axis.text=element_text(size=textsize,face="bold"),
        axis.text.x=element_text(angle = 0, hjust = 0.5,size=textsize, vjust=0.5,face="bold"),
        legend.key.size=unit(0.05,'in'),
        legend.title=element_blank(),
        legend.text=element_text(size=textsize,face="bold"),
        legend.position='right') +
  labs(y=expression(""),x=expression(bold("Genome Position")))

genomeplot <- ggplot(CoVgenome,
                     aes(xmin= start, xmax= end, y= "",fill = gene, label = gene)) +
  geom_gene_arrow(arrowhead_height = unit(3, "mm"), arrowhead_width = unit(1, "mm")) +
  geom_gene_label(align = "centre") +
  facet_wrap(~ molecule, scales = "free", ncol = 1) +
  scale_fill_brewer(palette = "Set3")+theme_genes()+
  theme(plot.title=element_blank(),
        axis.text.x=element_blank(),axis.title.y=element_blank(),
        legend.title=element_blank(),
        legend.position = "none"
  )


h <- length(graph)*0.78+3.5

t <- cowplot::plot_grid(genomeplot,p,align = "v", axis = "lr", ncol = 1, rel_heights = c(0.15, (h-3)/h))

ggsave("graph/genome_graph/Graph_2.png",t,
    width = 14, height = h, units = "cm", dpi = 300)