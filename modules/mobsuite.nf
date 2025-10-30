process MOBSUITE_RECON {
    tag "$sample_id"
    label 'process_medium'
    label 'mobsuite_container'

    publishDir "${params.output_dir}/mobsuite_results", mode: 'copy', pattern: "${sample_id}/*"

    input:
        tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}/chromosome.fasta")    , emit: chromosome
    tuple val(sample_id), path("${sample_id}/contig_report.txt")   , emit: contig_report
    tuple val(sample_id), path("${sample_id}/plasmid_*.fasta")     , emit: plasmids        
    tuple val(sample_id), path("${sample_id}/mobtyper_results.txt"), emit: mobtyper_results

    script:
    """
    mob_recon \\
        --infile ${assembly} \\
        --num_threads $task.cpus \\
        --outdir results \\
        --sample_id ${sample_id}
    mv results/ ${sample_id}
    """
}