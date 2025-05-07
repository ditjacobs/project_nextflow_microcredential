process formatting_variant_testing {
  publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
  container 'oras://community.wave.seqera.io/library/r-vcfr:1.10.0--249369387dddc693'
  //label "small"

  input: 
  tuple val(name), path(vcf), path(pheno)

  output: 
  path('*genotype.csv'), emit: genotype
  path('*phenotype.csv'), emit: phenotype
  val(name), emit: name

  script:
  """
  formatting.r ${vcf} ${pheno} ${name}
  """
}

process single_variant_testing { 
    publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
    container 'oras://community.wave.seqera.io/library/r-base:4.4.3--7be4e7faa3ce399e'
    //label "small"

    input: 
    path(genotype)
    path(phenotype)
    val(name)

    output: 
    path("*single_variant_results.csv"), emit: sv_results

    script: 
    """
    single_variant_test.r ${genotype} ${phenotype} ${name}
    """
}
/*
process gene_based_testing{
  publishDir "${params.outdir}/variant_testing", mode: "copy", overwrite: true 
    container 'community.wave.seqera.io/library/r-skat:2.2.5--1298e5fce9ac74b6'
    //label "small"

    input: 
    path(genotype)
    path(phenotype)
    val(name)

    output: 
    path("*rare_variant_results.csv"), emit: rv_results

    script: 
    """
    gene_based_test.r ${genotype} ${phenotype} ${name}
    """

}
*/

workflow association_testing { 
  take: 
    input
  main: 
    formatting_variant_testing(input)

    def geno =  formatting_variant_testing.out.genotype
    def pheno = formatting_variant_testing.out.phenotype 
    def vcfname = formatting_variant_testing.out.name

    sv_results = single_variant_testing(geno, pheno, vcfname)
    //rv_results = gene_based_testing(geno, pheno, vcfname)

  emit: 
    sv_results
    //rv_results    
}
