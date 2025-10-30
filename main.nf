#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { PORECHOP         } from './modules/preprocess'
include { NANOPLOT         } from './modules/preprocess'
include {DRAGONFLYE        } from './modules/long_assemblers'
include {AUTOCYCLER        } from './modules/long_assemblers'
include {QUAST             } from './modules/assembly_assess'
include {AMRFINDERPLUS_RUN } from './modules/amrfinder'
include {MOBSUITE_RECON    } from './modules/mobsuite'
include {PLASMIDFINDER    } from './modules/plasmidfinder'



workflow {

    // Check mandatory params
    if( !params.input_dir ) {
        error "Pleas use --input_dir to specify folder containing nanopore reads."
    }

    // Check input directory exists
    if( !file(params.input_dir).exists() ) {
        error "Input directory '${params.input_dir}' does not exist."
    }
    if( !file(params.output_dir).exists() ) {
        println "Creating output directory '${params.output_dir}'."
        file(params.output_dir).mkdirs()
    } else {
        println "Overwriting results in existing output directory '${params.output_dir}'."
    }

    // ─────────────────────────────────────────────
    // 1️⃣  Input handling
    // ─────────────────────────────────────────────
    if (params.assemblies) {
        log.info "Assemblies directory provided: ${params.assemblies}"
    
        // Pick up .fasta or .fa files
        channel
            .fromPath("${params.assemblies}/*.{fa,fasta}", checkIfExists: true)
            .ifEmpty { error "No FASTA files found in assemblies directory '${params.assemblies}'." }
            .map { file ->
                def sample_id = file.baseName.replaceFirst(/(\.fa|\.fasta)$/, '')
                tuple(sample_id, file)
            }
            .set { assemblies_ch }

    } else {
        log.info "No assemblies provided — starting from raw FASTQ reads in '${params.input_dir}'"

        channel
            .fromPath("${params.input_dir}/*.{fastq,fastq.gz}", checkIfExists: true)
            .ifEmpty { error "No FASTQ files found in input directory '${params.input_dir}'." }
            .map { file -> 
                def base = file.baseName

                // Identify Illumina-style paired-end reads to skip
                def illumina = base ==~ /.*(_1|_2|_R1|_R2)(\.fastq(\.gz)?)?$/
                if (illumina) {
                    def sample_id = base.replaceFirst(/(\.fastq(\.gz)?)$/, '')
                    println "Ignoring Illumina-style file: ${file} (sample: ${sample_id})"
                    return null
                }

                def sample_id = base.replaceFirst(/(\.fastq(\.gz)?)$/, '')
                tuple(sample_id, file)
                }
            .filter { it != null }
            .set { fastq_files }

    // ─────────────────────────────────────────────
    // 2️⃣  Run assembly workflow
    // ─────────────────────────────────────────────
    PORECHOP(fastq_files)
    NANOPLOT(PORECHOP.out)

    if (params.assembler == 'autocycler') {
        AUTOCYCLER(PORECHOP.out, params.read_type)
        assemblies_ch = AUTOCYCLER.out.assembly
    } else {
        DRAGONFLYE(PORECHOP.out, params.medaka_model)
        assemblies_ch = DRAGONFLYE.out
    }
    }

    // ─────────────────────────────────────────────
    // 3️⃣  Common downstream step
    // ─────────────────────────────────────────────
    assemblies_ch.set { assemblies }    

    //assess assembly using quast
    QUAST(assemblies_ch)

    //run amrfinderplus
    AMRFINDERPLUS_RUN(assemblies_ch)

    //run mobsuite
    MOBSUITE_RECON(assemblies_ch)

    //run plasmidfinder
    PLASMIDFINDER(assemblies_ch)
    
}