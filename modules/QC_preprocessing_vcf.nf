process multiallelic_splitting{ 
    publishDir "${params.outdir}/QC", mode: "copy", overwrite: true
    container "oras://community.wave.seqera.io/library/bcftools:1.21--21573c18b3ab6bcb"
    //label "small"

    input:
    tuple val(filename), path(VCFfile)

    output: 
    path("${filename}_split.vcf"), emit: vcf_split
    
    script: 
    """
    bcftools norm -m -both ${VCFfile} -o "${filename}_split.vcf"
    """
}