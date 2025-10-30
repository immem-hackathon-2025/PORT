process PLASMIDFINDER {

    tag "$sample_id"
    label 'process_medium'
    label 'plasmidfinder_container'

    publishDir "${params.output_dir}/plasmidfinder", mode: 'copy'

    input:
        tuple val(sample_id), path(fasta)

    output:
        tuple val(sample_id), path("${sample_id}_genome_seq.fsa"),        emit: genome_seq
        tuple val(sample_id), path("${sample_id}_plasmid_seqs.fsa"),      emit: plasmid_seq
        tuple val(sample_id), path("${sample_id}_plasmidfinder.tsv"),     emit: plasmidfinder_report

    script:
    """
    # create output dir
    mkdir -p plasmidfinder_out

    # run plasmidfinder
    plasmidfinder.py \
        -i ${fasta} \
        -o plasmidfinder_out \
        -x

    # rename report for easier identification
    mv plasmidfinder_out/results_tab.tsv ${sample_id}_plasmidfinder.tsv || true
    mv plasmidfinder_out/Hit_in_genome_seq.fsa ${sample_id}_genome_seq.fsa || true
    mv plasmidfinder_out/Plasmid_seqs.fsa ${sample_id}_plasmid_seqs.fsa || true
    """
}
