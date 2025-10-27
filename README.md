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

- Input: Folder containing raw Nanopore reads (FASTQ format)
- Quality control and trimming using [Porechop](https://github.com/rrwick/Porechop)
- Assembly of trimmed reads (assembler to be specified)
- Modular and easy to use

## Usage

1. Place your raw Nanopore reads in a folder.
2. Run the PORT pipeline, specifying the input folder and output directory.

```bash
nextflow run main.nf --input_dir input_folder --output_dir output_folder -resume
```

## Requirements

- Python 3.8+
- Porechop
- (Specify assembler, e.g., Flye, Canu, etc.)

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

Run the pipeline using Nextflow:

```bash
nextflow run main.nf --input /path/to/reads --output /path/to/results
```
```

## Pipeline Steps

1. **Quality Control & Trimming:**  
    Raw reads are processed with Porechop to remove adapters and low-quality regions.

2. **Assembly:**  
    Trimmed reads are assembled using the specified assembler (e.g., Autoculer or Dragonflye). 
    The user can select which assembler to use by providing it as an input parameter `--assembler`.

## Output

- Assembled plasmid sequences (FASTA)
- QC reports
- AMR reports
- MGE reports
- Mobsuite reports
- Plasmids
- Log files

## Citation

If you use PORT in your research, please cite this repository.

## License

Distributed under the MIT License.