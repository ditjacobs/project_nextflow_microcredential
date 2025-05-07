#!/usr/bin/env nextflow

// Set default parameters
// General Parameters
params.datadir = "${projectDir}/data"
params.outdir = "${projectDir}/results"

// Input parameters
params.vcfpath = "${params.datadir}/*.vcf"
params.pheno = "${params.datadir}/*.csv"

// include modules and subworkflows
include {multiallelic_splitting} from './modules/QC_preprocessing_vcf'
include {monomorphic} from './modules/variant_filtering'
include {association_testing} from './modules/variant_testing'
include {create_report} from './modules/report_results'

workflow { 
  //Set input data
  def input_VCF = Channel.fromPath(params.vcfpath).map{ file -> tuple(file.baseName, file)}
  
  // Split multiallelic variants 
  multiallelic_splitting(input_VCF)

  //Set new input based on vcf from splitting 
  multiallelic_splitting.out.vcf_split.map{ file -> tuple(file.baseName, file)}.set{input_VCF_monomorph}

  //filter out all monomorphic variants 
  monomorphic(input_VCF_monomorph)

  //Run association analysis 
  // find common part of vcf and pheno file names to match them correctly 
  Channel.fromPath(params.pheno)
    .map { file ->   
      def id = file.name.split('_')[0]    
      return [id, file] 
    }
    .set{ pheno }
  monomorphic.out.vcf_filter_monomorph
    .map{file -> 
      def id=  file.name.split('_')[0] 
      return [id, file] 
    }
    .set{vcf}
  //join the pheno and vcf file based on the id 
  vcf.join(pheno).set{input_association}
  vcf.join(pheno).view()
  //view if the input was correctly matched 
  //name = "lol"
  results = association_testing(input_association)
  
  // create report
  results.merge().collect().set{input_report}
  create_report(input_report)
}
