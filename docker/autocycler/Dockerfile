# ==============================
# Base Image
# ==============================
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------
# Install essential packages
# ------------------------------
RUN apt-get update && apt-get install -y \
    wget curl git parallel bzip2 ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# ------------------------------
# Install Miniconda
# ------------------------------
WORKDIR /opt
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
ENV PATH="/opt/conda/bin:$PATH"

RUN conda config --set channel_priority  strict && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge 

# Accept Terms of Service for Anaconda channels
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN apt-get update && apt-get install -y build-essential

# ------------------------------
# Copy environment file & create env
# ------------------------------
COPY environment.yml /opt/environment.yml
RUN conda env create -f /opt/environment.yml --name autocycler && conda clean -a -y

# ------------------------------
# Set environment
# ------------------------------
ENV PATH="/opt/conda/envs/autocycler/bin:$PATH"
ENV CONDA_DEFAULT_ENV=autocycler
ENV CONDA_PREFIX=/opt/conda/envs/autocycler
RUN conda init bash

#USER root
# --------------------------------------------------
# Download Plassembler DB inside conda environment
# --------------------------------------------------
RUN /bin/bash -c "source /opt/conda/bin/activate autocycler && \
    plassembler download -d \$CONDA_PREFIX/plassembler_db"

ENV PLASSEMBLER_DB="/opt/conda/envs/autocycler/plassembler_db"

RUN conda run -n autocycler pip install paralleltask


# Patch Plassembler to handle Unicycler version parsing robustly
RUN sed -i 's/unicycler_out = unicycler_out.decode()/unicycler_out = unicycler_out.decode().strip()/' \
    /opt/conda/envs/autocycler/lib/python3.12/site-packages/plassembler/utils/input_commands.py

## Fix NextPolish Python interpreter and dependencies
RUN sed -i '1s|.*|#!/opt/conda/envs/autocycler/bin/python|' /opt/conda/envs/autocycler/bin/nextPolish

RUN sed -i 's/process = sp.Popen(\["unicycler", "--version".*/unicycler_out = "Unicycler v0.5.1"/' /opt/conda/envs/autocycler/lib/python3.12/site-packages/plassembler/utils/input_commands.py
#RUN sed -i '/process = sp.Popensp.Popen(["unicycler", "--version"]/,/process.communicate()/c\        unicycler_out = "Unicycler v0.5.1"' /opt/conda/envs/autocycler/lib/python3.12/site-packages/plassembler/utils/input_commands.py
RUN sed -i 's/unicycler_out, _ = process.communicate()/unicycler_out = b"Unicycler v0.5.1"/' /opt/conda/envs/autocycler/lib/python3.*/site-packages/plassembler/utils/input_commands.py

# --------------------------------------------------
# Set working directory
# --------------------------------------------------
# Ensure all env binaries are globally visible
ENV PATH="/opt/conda/envs/autocycler/bin:$PATH"

WORKDIR /data
CMD ["autocycler", "--help"]
