<p align="center">
    <img src="https://www.nextflow.io/img/logo.png" alt="Nextflow Logo" height="60"/>
    &nbsp;&nbsp;
    <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" alt="Docker Logo" height="60"/>
</p>

# Plasmid Outbreak Reporting Tool (PORT)

<p align="center">
    <a href="https://creativecommons.org/licenses/by/4.0/">
        <img src="https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by.png" alt="CC BY 4.0 License" height="31"/>
    </a>
</p>
## Overview

PORT (Plasmid Outbreak Reporting Tool) is a pipeline designed to process Oxford Nanopore sequencing reads for plasmid outbreak analysis. It automates quality control, trimming, and assembly steps to generate high-quality plasmid assemblies from raw sequencing data.

## Features

- Input: Folder containing raw Nanopore reads (FASTQ format)
- Quality control and trimming using [Porechop](https://github.com/rrwick/Porechop)
- Assembly of trimmed reads (assembler to be specified)
- Modular and easy to use

## Usage

1. Place your raw Nanopore reads in a folder.
2. Run the PORT pipeline, specifying the input folder and output directory.

```bash
port --input /path/to/reads --output /path/to/results
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
    Trimmed reads are assembled using the specified assembler (e.g., Autoculer or Draginflye). The user can select which assembler to use by providing it as an input parameter.

## Output

- Assembled plasmid sequences (FASTA)
- QC reports
- Log files

## Citation

If you use PORT in your research, please cite this repository.

## License

Distributed under the MIT License.