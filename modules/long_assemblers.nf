process DRAGONFLYE {
    tag "$sample_id"

    label 'process_high'
    label'dragonflye_container'

    publishDir "${params.output_dir}/assemblies", mode: 'copy'

    input:
        tuple val(sample_id), path(reads)
        val(medaka_model)

    output:
        tuple val(sample_id), path(fasta)

    script:
    LR="$reads"
    fasta="${sample_id}.long.fasta"
    """
    dragonflye --reads $LR --cpus $task.cpus --ram $task.memory \
    --prefix $sample_id --racon 1 --medaka 1 --model $medaka_model \
    --outdir "$sample_id" --force --keepfiles --depth 150
    mv "$sample_id"/"$sample_id".fa $fasta
    """
}

process AUTOCYCLER {
    tag "$sample_id"

    label 'process_high'
    label'autocycler_container'

    publishDir "${params.output_dir}/assemblies", mode: 'copy'
    
    input:
        tuple val(sample_id), path(reads)
        val(read_type)
    
    output:
        tuple val(sample_id), path("${sample_id}_assembly.fasta"), emit: assembly
        tuple val(sample_id), path("${sample_id}_assembly_graph.gfa"), emit: assembly_graph

    script:
    """
    autocycler.sh $reads $task.cpus 4 $read_type
    mv autocycler_out/consensus_assembly.fasta ${sample_id}_assembly.fasta
    mv autocycler_out/consensus_assembly.gfa ${sample_id}_assembly_graph.gfa
    """
}