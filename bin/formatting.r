#!/usr/bin/env Rscript
library("vcfR")

args = commandArgs(trailingOnly=TRUE)
vcf <- args[1]
pheno <- args[2]
name <- args[3]

#read in the files from the path
vcf <- read.vcfR(vcf)
pheno <- read.csv(pheno, row.names = 1) 
#Extract the genotypes from the vcf file
gt <- extract.gt(vcf)

# Put the genotypes in correct genotype matrix format 
# Convert genotypes to 0, 1, 2, NA format
Z <- matrix(NA, nrow = nrow(gt), ncol = ncol(gt))
Z[gt == "0"] <- 0
Z[gt == "1"] <- 1
Z[gt == "2"] <- 2
# note: all NA remain NA

colnames(Z) <- colnames(gt)
rownames(Z) <- rownames(gt)

#How many SNPs are homozygous (ref vs. alt), heterozygous
#table(Z)

#transpose and transform to dataframe

Z <- t(Z)
Z <- as.data.frame(Z)

# Remove double samples from families (Note: not reproducible, but necessary for this analysis)
#pheno_names <- pheno[pheno$new_phenotype == '.', 1]
#Exclude all samples from families
#Z <- Z[!(rownames(Z) %in% pheno_names),]

# Merge to get the same order in genotype matrix and phenotype by sample name

Z <- cbind(rownames(Z), Z)
colnames(Z)[1] <- colnames(pheno[1])
merged <- merge(Z, pheno) #now the . phenotypes are removed

#select only variant information 
gt <- merged[, grep("MT",colnames(merged))] 

output_genotype <- paste(name, "genotype.csv", sep ="_")
write.csv(gt, output_genotype )

#select the phenotype information from the 
pheno_ordered <- merged[, c("new_phenotype", "sample_name")]

output_phenotype <- paste(name,  "phenotype.csv", sep ="_")
write.csv(pheno_ordered, output_phenotype)
