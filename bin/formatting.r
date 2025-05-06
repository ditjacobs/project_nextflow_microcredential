#!/usr/bin/env Rscript
library("vcfR")

args = commandArgs(trailingOnly=TRUE)
vcf <- args[1]
pheno <- args[2]

#read in the files from the path
vcf <- read.vcfR(vcf)
pheno <- read.csv(pheno, row.names = 1) 
#Extract the genotypes from the vcf file
GT <- extract.gt(vcf)

# Put the genotypes in correct genotype matrix format 
# Convert genotypes to 0, 1, 2, NA format
Z <- matrix(NA, nrow = nrow(GT), ncol = ncol(GT))
Z[GT == "0/0" | GT == "0|0"] <- 0
Z[GT == "0/1" | GT == "1/0" | GT == "0|1" | GT == "1|0"] <- 1
Z[GT == "1/1" | GT == "1|1"] <- 2
# note: all NA remain NA
colnames(Z) <- colnames(GT)
rownames(Z) <- rownames(GT)

#How many SNPs are homozygous (ref vs. alt), heterozygous
table(Z)

#transpose and transform to dataframe
Z <- t(Z)
Z <- as.data.frame(Z)

# Remove double samples from families (Note: not reproducible, but necessary for this analysis)
pheno_names <- pheno[pheno$new_phenotype == '.', 1]
#Exclude all samples from families
Z <- Z[!(rownames(Z) %in% pheno_names),]

# Merge to get the same order in genotype matrix and phenotype by sample name
Z <- cbind(rownames(Z), Z)
colnames(Z)[1] <- colnames(pheno[1])
merged <- merge(Z, pheno) #now the . phenotypes are removed

#select only variant information 
gt <- merged[, grep("chr",colnames(merged))] 

write.csv(gt, "genotype.csv")

#select the phenotype information from the 
pheno_ordered <- merged[, c("new_phenotype", "sample_name")]

write.csv(pheno_ordered, "phenotype.csv")
