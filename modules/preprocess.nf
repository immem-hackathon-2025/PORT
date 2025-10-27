process PORECHOP {
    
    tag "$sample_id"

    label 'porechop_container'
    label 'process_high'
    
    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("trimmed_${sample_id}.fastq.gz")

    script:
    
    LR="${reads}"
    preprocessed_ont="trimmed_${sample_id}.fastq.gz"

    """
    porechop -i $LR -o $preprocessed_ont -t $task.cpus
    """

}

process NANOPLOT {
    
    tag { sample_id }
    
    label 'process_low'
    label 'nanoplot_container'

    publishDir "${params.output_dir}/long_read_stats", mode: 'copy', pattern: '*.html'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*.html"), emit: html

    script:
    LR="${reads}"

    """
    NanoPlot --fastq $LR -t $task.cpus -o nanoplot_out --no_static
    mv nanoplot_out/NanoPlot-report.html ${sample_id}_nanoplot_report.html
    """
}