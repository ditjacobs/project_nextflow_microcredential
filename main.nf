#!/usr/bin/env nextflow

// General Parameters
params.datadir = "${launchDir}/data"
params.outdir = "${launchDir}/results"

// Input parameters
params.vcfpath = "${params.datadir}/SMARCA4_VCF.vcf"
params.pheno = "${params.datadir}/SMARCA4_phenotype.csv"

// include modules and subworkflows
include {multiallelic_splitting} from './modules/QC_preprocessing_vcf'
include {monomorphic} from './modules/variant_filtering'
include {formatting_variant_testing; single_variant_testing; gene_based_testing} from './modules/variant_testing'
include {create_report} from './modules/report_results'

workflow { 
  //Set input data
  def input_VCF = Channel.fromPath(params.vcfpath).map{ file -> tuple(file.baseName, file)}
  
  // Split multiallelic variants 
  multiallelic_splitting(input_VCF)

  //Set new input based on vcf from splitting 
  multiallelic_splitting.out.vcf_split.map{ file -> tuple(file.baseName, file)}.set{input_VCF_monomorph}

  //filter out all monomorph variants 
  monomorphic(input_VCF_monomorph)

  //Run association analysis 
  //Necessary inputs are: vcf after QC and filtering and 
  //Channel.fromPath(params.pheno).view()
  //monomorphic.out.vcf_filter_monomorph.view()
  //Channel.fromPath(params.pheno).join(monomorphic.out.vcf_filter_monomorph).view()
  def pheno = channel.fromPath(params.pheno)
  formatting_variant_testing(monomorphic.out.vcf_filter_monomorph, pheno)
  //
  single_variant_testing(formatting_variant_testing.out.genotype, formatting_variant_testing.out.phenotype)
  gene_based_testing(formatting_variant_testing.out.genotype, formatting_variant_testing.out.phenotype)
  
  single_variant_testing.out.sv_results.merge(gene_based_testing.out.rv_results).collect().set{input_report}
  create_report(input_report)
  
}
