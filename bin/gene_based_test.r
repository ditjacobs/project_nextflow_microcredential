#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
geno <- args[1]
pheno <- args[2]

geno <- read.csv(geno, header = TRUE)
pheno <- read.csv(pheno, header = TRUE)

library(SKAT)

gene_based_test <- function(genotype, phenotype){
  # Step 1: Create a list named SSD containing the genotype matrix (Z) and the phenotype vector (y.b)
  # - 'genotype' is converted to a matrix and stored as 'Z'
  # - 'phenotype$new_phenotype' is extracted and stored as 'y.b'
  SSD <- list(Z = as.matrix(genotype), y.b = phenotype$new_phenotype)
  
  # Step 2: Create a null model using SKAT_Null_Model
  # - Model: y.b ~ 1 (intercept only, no covariates)
  # - out_type = "D" indicates binary outcome (D = Dichotomous)
  # - SSD is passed for compatibility with the SKAT function
  obj <- SKAT_Null_Model(y.b ~ 1,out_type = "D", SSD)
  
  # Step 3: Perform burden test (BT)
  # - r.corr = 1 indicates a pure burden test
  # - max_maf = 0.01 restricts the test to variants with MAF ≤ 1%
  BT <- SKAT(SSD$Z, obj, r.corr=1, max_maf = 0.01)
  
  # Step 4: Perform variance-component test (VCT)
  # - r.corr = 0 indicates a pure SKAT (variance-component) test
  VCT <- SKAT(SSD$Z, obj, r.corr=0, max_maf = 0.01)
  
  # Step 5: Perform SKAT-O test (hybrid of burden and SKAT)
  # - method = "SKATO" runs the combined test
  SKATO <- SKAT(SSD$Z, obj, method="SKATO", max_maf = 0.01)
  
  # Step 6: Return the p-values from all three tests as a vector
  return(data.frame(BT_pvalue = BT$p.value, VC_pvalue = VCT$p.value, SKATO_pvalue = SKATO$p.value))
}


pvalues <- gene_based_test(geno, pheno)

write.csv(pvalues, "rare_variant_results.csv")