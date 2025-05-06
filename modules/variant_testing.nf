process formatting_variant_testing {
  publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
  container 'oras://community.wave.seqera.io/library/r-vcfr:1.10.0--249369387dddc693'
  //label "small"

  input: 
  path(vcf)
  path(pheno)

  output: 
  path('genotype.csv'), emit: genotype
  path('phenotype.csv'), emit: phenotype

  script:
  """
  formatting.r ${vcf} ${pheno}
  """
}

process single_variant_testing { 
    publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
    container 'oras://community.wave.seqera.io/library/r-base:4.4.3--7be4e7faa3ce399e'
    //label "small"

    input: 
    path(genotype)
    path(phenotype)

    output: 
    path("single_variant_results.csv"), emit: sv_results

    script: 
    """
    single_variant_test.r ${genotype} ${phenotype}
    """
}

process gene_based_testing{
  publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
    container 'community.wave.seqera.io/library/r-skat:2.2.5--1298e5fce9ac74b6'
    //label "small"

    input: 
    path(genotype)
    path(phenotype)

    output: 
    path("rare_variant_results.csv"), emit: rv_results

    script: 
    """
    gene_based_test.r ${genotype} ${phenotype}
    """

}
