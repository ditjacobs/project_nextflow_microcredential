#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
geno <- args[1]
pheno <- args[2]
name <- args[3]

geno <- read.csv(geno, header = TRUE)
pheno <- read.csv(pheno, header = TRUE)
single_variant_test <- function(genotype, phenotype) {
  # Initialize an empty data frame to store results:
  # Each row will contain the SNP name and the associated p-value (for MAF > 0.01)
  results <- data.frame(SNP = character(), p_value = numeric())
  
  # Prepare to store Minor Allele Frequencies (MAFs) and contingency table data
  MAF <- numeric(ncol(genotype))
  contingency_data <- data.frame(
    ref_case = numeric(),
    ref_control = numeric(),
    alt_case = numeric(),
    alt_control = numeric()
  )
  
  # Loop through each SNP (column in genotype matrix)
  for (i in 1:ncol(genotype)) {
    # Skip SNPs that have no variability (e.g., only one genotype or all NA)
    if (length(table(genotype[, i])) > 1) {
      
      # Merge the SNP genotypes with phenotype data
      data_merged <- data.frame(
        genotype_i = genotype[, i],
        new_phenotype = phenotype$new_phenotype
      )
      
      # Split the data into cases and controls
      cases <- data_merged[data_merged$new_phenotype == 1, ]
      controls <- data_merged[data_merged$new_phenotype == 0, ]
      
      # Count reference and alternate alleles for cases
      ref_case <- sum(cases$genotype_i == 0, na.rm = TRUE) * 2 +
        sum(cases$genotype_i == 1, na.rm = TRUE)
      alt_case <- sum(cases$genotype_i == 2, na.rm = TRUE) * 2 +
        sum(cases$genotype_i == 1, na.rm = TRUE)
      
      # Count reference and alternate alleles for controls
      ref_control <- sum(controls$genotype_i == 0, na.rm = TRUE) * 2 +
        sum(controls$genotype_i == 1, na.rm = TRUE)
      alt_control <- sum(controls$genotype_i == 2, na.rm = TRUE) * 2 +
        sum(controls$genotype_i == 1, na.rm = TRUE)
      
      # Calculate Minor Allele Frequency (MAF) in controls
      MAF_alt <- alt_control / (2 * nrow(controls))
      MAF[i] <- MAF_alt
      
      # Perform Fisher’s exact test only for variants with MAF > 0.01
      if (MAF_alt >= 0.01) {
        # Create a 2x2 contingency table: rows = alleles, columns = control/case
        contingency_table <- matrix(
          c(ref_control, ref_case, alt_control, alt_case),
          ncol = 2,
          byrow = TRUE
        )
        # Perform Fisher’s exact test
        test_result <- fisher.test(contingency_table)
        
        # Store the SNP name and p-value
        results <- rbind(results, data.frame(
          SNP = colnames(genotype)[i],
          p_value = test_result$p.value
        ))
      }
    }
  }
  
  # Return the final results data frame
  return(results)
}

pvalues <- single_variant_test(geno, pheno)

pvalues_sorted <- pvalues[order(pvalues$p_value),]

adjusted_pvalues <- p.adjust(pvalues_sorted$p_value, method = "bonferroni")

pvalues_sorted_corrected <- cbind(pvalues_sorted, adjusted_pvalues)

output <- paste(name, "single_variant_results.csv", sep ="_")
write.csv(pvalues_sorted_corrected, output)