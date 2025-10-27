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

RUN conda install python=3.12 -y

# Accept Terms of Service for Anaconda channels
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
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


# --------------------------------------------------
# Download Plassembler DB inside conda environment
# --------------------------------------------------
RUN /bin/bash -c "source /opt/conda/bin/activate autocycler && \
    plassembler download -d \$CONDA_PREFIX/plassembler_db"

ENV PLASSEMBLER_DB="/opt/conda/envs/autocycler/plassembler_db"

RUN pip install paralleltask

# Patch Plassembler to handle Unicycler version parsing robustly
RUN sed -i 's/unicycler_out = unicycler_out.decode()/unicycler_out = unicycler_out.decode().strip()/' \
    /opt/conda/envs/autocycler/lib/python3.12/site-packages/plassembler/utils/input_commands.py

# --------------------------------------------------
# Set working directory
# --------------------------------------------------
# Ensure all env binaries are globally visible
ENV PATH="/opt/conda/envs/autocycler/bin:$PATH"

WORKDIR /data
CMD ["autocycler", "--help"]
