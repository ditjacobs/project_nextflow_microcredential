process create_report{
    publishDir "${params.outdir}/", mode: "copy", overwrite: true
    label "low"

    input:
    path(inputfiles)

    output:
    path("report.txt")

    script:
    """
    echo "Content file $inputfiles" >> report.txt
    cat $inputfiles >> report.txt
    """
}

