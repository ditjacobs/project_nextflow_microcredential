process multiallelic_splitting{ 
    publishDir "${params.outdir}/QC", mode: "copy", overwrite: true
    container "quay.io/biocontainers/bcftools:1.4--0" 
    label "low"

    input:
    tuple val(filename), path(VCFfile)

    output: 
    path("*_split.vcf"), emit: vcf_split
    
    script: 
    """
    bcftools norm -m -both ${VCFfile} -o "${filename}_split.vcf"
    """
}