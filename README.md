[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

# Plasmid Outbreak Reporting Tool (PORT)

<p align="center">
    <a href="https://creativecommons.org/licenses/by/4.0/">
        <img src="https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by.png" alt="CC BY 4.0 License" height="31"/>
    </a>
</p>

## Overview

PORT (Plasmid Outbreak Reporting Tool) is a pipeline designed to process Oxford Nanopore sequencing reads for plasmid outbreak analysis. It automates quality control, trimming, and assembly steps to generate high-quality plasmid assemblies from raw sequencing data.

## Authors

Jia Qi Beh, Varun Shamamna, Célia Souque, Andreza Francisco Martins, Henrik Hasman, Louise Roer

## Features

- **Input:**
  - Folder containing raw **Nanopore FASTQ** files (default: `--input_dir`)
  - OR folder containing pre-assembled **FASTA** files (using `--assemblies`)
- Automatic **adapter trimming and quality control** using [Porechop](https://github.com/rrwick/Porechop)
- **Assembly** of Nanopore reads using a user-selected assembler (`--assembler`), such as:
  - [Autocycler](https://github.com/rrwick/Autocycler)
  - [Dragonflye](https://github.com/rpetit3/Dragonflye)

---
## Installation

Clone the repository and install dependencies:

```bash
Make sure you have [Docker](https://www.docker.com/) installed and running.

Install [Nextflow](https://www.nextflow.io/) if you haven't already:

```bash
curl -s https://get.nextflow.io | bash
```

Clone the repository:

```bash
git clone https://github.com/your-org/PORT.git
cd PORT
```

## ⚙️ Usage

### 1. Run with raw Nanopore reads (default mode)

Place all FASTQ/FASTQ.GZ files in your input folder and run:

```bash
nextflow run main.nf --input_dir /path/to/reads --output_dir /path/to/results --assembler autocycler -resume
```
The pipeline will:

 - Perform QC and adapter trimming using Porechop

 - Assemble reads using the chosen assembler

 - Run QUAST on the assembled genomes

### 2. Run with pre-assembled genomes (FASTA input)

If assemblies are already available, you can skip the read processing steps by providing the --assemblies option:

```bash
nextflow run main.nf --assemblies /path/to/assemblies --output_dir /path/to/results -resume
```

## 🧩 Pipeline Steps

1. **Input Handling:**  
   The pipeline automatically detects whether the user has provided:
   - Raw Nanopore reads (`--input_dir`, default), or  
   - Pre-assembled genomes (`--assemblies`)  

   If both are given, the pipeline will prioritise **assemblies**.

2. **Quality Control & Trimming:**  
   When FASTQ reads are used as input, they are processed using **Porechop** to remove adapters and low-quality regions.

3. **Assembly:**  
   Trimmed reads are assembled using the user-specified assembler (`--assembler`), which can be:
   - **Autocycler** – for hybrid and circular bacterial genome assembly  
   - **Dragonflye** – for long-read-only assembly and polishing  

4. **Post-assembly Evaluation:**  
   All assemblies (from FASTQ or FASTA input) are evaluated using **QUAST** and other downstream tools.

5. **AMRFinder Analysis:**  
   Detection of antimicrobial resistance (AMR) genes using [NCBI AMRFinderPlus](https://github.com/ncbi/amr).  
   The results include identified resistance genes, their drug classes, and associated gene families.

6. **MOB-suite Analysis:**  
   Comprehensive plasmid typing and reconstruction using [MOB-suite](https://github.com/phac-nml/mob-suite).  
   This step performs:
   - Plasmid clustering and separation from chromosomal contigs  
   - Replicon typing and relaxase identification  
   - Mobility classification (MOB, CONJ, or non-mobilisable)  
   - Prediction of plasmid transmissibility and host range.

7. **PlasmidFinder Analysis:**  
   Detection of plasmid replicon markers using [PlasmidFinder](https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/).  
   The tool identifies incompatibility groups (Inc types) and provides replicon-based classification for detected plasmids.


### 💡 Parameters

| Parameter        | Description                                     | Default                |
| ---------------- | ----------------------------------------------- | ---------------------- |
| `--input_dir`    | Directory containing FASTQ files                | `input/`               |
| `--assemblies`   | Directory containing pre-assembled FASTA files  | `null`                 |
| `--output_dir`   | Output directory for all results                | `output/`              |
| `--assembler`    | Assembler to use (`autocycler` or `dragonflye`) | `autocycler`           |
| `--read_type`    | Read type (e.g., `ont_r9`)                      | `ont_r10`              |
| `--medaka_model` | Medaka model (for Dragonflye polishing)         | `r1041_e82_400bps_sup` |


## 🧾 Output

The pipeline produces the following outputs in the specified `--output_dir`:

| Output Type | Description |
|--------------|-------------|
| **Assembled plasmid sequences (FASTA)** | Final genome or plasmid assemblies generated after polishing and circularisation |
| **QC reports** | Read-level quality statistics and adapter trimming results from Porechop |
| **AMR reports** | Detection of antimicrobial resistance genes using curated AMR databases |
| **MGE reports** | Identification of mobile genetic elements (integrons, transposons, insertion sequences, etc.) |
| **MOB-suite reports** | Comprehensive plasmid typing using [MOB-suite](https://github.com/phac-nml/mob-suite). Includes plasmid clustering, replicon typing, relaxase typing, and mobility classification to predict plasmid transmissibility. |
| **PlasmidFinder reports** | Detection of plasmid replicon markers using [PlasmidFinder](https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/), providing plasmid incompatibility group information. |
| **Plasmid FASTAs** | Predicted plasmid sequences reconstructed from assemblies. |
| **Log files** | Execution logs for each process, including assembly steps, QC summaries, and downstream analyses. |

Each result is organised under subfolders such as `long_read_stats/`, `assemblies/`, `quast_summary/`, `amrfinder_results/`, `mobsuite_results/`, and `logs/` within the output directory.

## Citation

If you use PORT in your research, please cite this repository.

## License

Distributed under the MIT License.