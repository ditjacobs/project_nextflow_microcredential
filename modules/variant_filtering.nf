process monomorphic{
    publishDir "${params.outdir}/filtering", mode: "copy", overwrite: true
    //container "oras://community.wave.seqera.io/library/bcftools:1.21--21573c18b3ab6bcb"
    container "quay.io/biocontainers/bcftools:1.3--0"
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