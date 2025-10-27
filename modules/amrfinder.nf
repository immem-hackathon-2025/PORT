process AMRFINDERPLUS_RUN {
    tag "$sample_id"
    label 'process_medium'

    input:
    tuple val(sample_id), path(fasta)

    output:
    tuple val(sample_id), path("${prefix}.tsv"), emit: report

    script:
    prefix   = "${sample_id}_amrfinder"

    """
    amrfinder -n $fasta -o ${prefix}.tsv --threads $task.cpus --name "$sample_id"
    """
}