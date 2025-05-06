process multiallelic_splitting{ 
    publishDir "${params.outdir}/QC", mode: "copy", overwrite: true
    container "oras://community.wave.seqera.io/library/bcftools:1.21--21573c18b3ab6bcb"
    //label "small"

    input:
    tuple val(filename), path(VCFfile)
    output: 
    path('*.vcf'), emit: vcf_split

    script: 
    """
    bcftools norm -m -both ${VCFfile} -o "${filename}_split.vcf"
    """
}

/*
process left_normalization { 
    publishDir "${params.outdir}/QC", mode: "copy", overwrite: true
    container "quay.io/biocontainers/bcftools:1.4--0"
    label "small"

    input:
    tuple val(filename), path(VCFfile)
    path(reference_genome)

    output:
    path('*.vcf'), emit: vcf_normalized

    script:
    """
    bcftools norm -f ${reference_genome} ${VCFfile} -o "${filename}_normalized.vcf"
    """
}
*/