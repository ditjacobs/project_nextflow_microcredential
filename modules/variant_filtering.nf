process monomorphic{
    publishDir "${params.outdir}/filtering", mode: "copy", overwrite: true
    container "quay.io/biocontainers/bcftools:1.4--0"
    label "low"
    
    input:
    tuple val(filename), path(VCFfile)

    output:
    path('*.vcf'), emit: vcf_filter_monomorph

    script:
    """
    bcftools view -e 'AC=0 || AC=AN || AC=0 && AN=0' ${VCFfile} -o ${filename}_monomorph.vcf
    """
}