process QUAST {
    tag "$sample_id"
    
    label 'process_single'
    label 'quast_container'
    
    publishDir "${params.outdir}/quast_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}.tsv"), emit: report
    tuple val(sample_id), env('assembly_length'), emit: assembly_length
    tuple val(sample_id), path("ori_${sample_id}.report.tsv"), emit: orireport

    script:
    report="${sample_id}.tsv"
    orireport="ori_${sample_id}.report.tsv"
    """
    quast.py -o results "$assembly"
    bash transpose_tsv.sh results/report.tsv > ${report}
    mv results/report.tsv ${orireport}
    assembly_length=\$(awk 'BEGIN {total_bases=0} !/^>/ {total_bases += length(\$0)} END {print total_bases}' ${assembly})
    """
}