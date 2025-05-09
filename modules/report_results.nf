process create_report{
    publishDir "${params.outdir}/", mode: "copy", overwrite: true
    label "low"

    input:
    path(inputfiles)

    output:
    path("report.txt")

    script:
    """
    for file in ${inputfiles}; do 
        echo "Content file $inputfiles" >> report.txt
        cat $inputfiles >> report.txt
        echo -e "\n"  >> report.txt
    done
    """
}

