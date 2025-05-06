process create_report{
    publishDir "${params.outdir}/", mode: "copy", overwrite: true
    //label "small"

    input:
    path(inputfiles)

    output:
    path("report.txt")

    script:
    """
    cat ${inputfiles} > report.txt
    """
}

