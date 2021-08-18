FROM continuumio/miniconda3 as build

RUN apt-get update && apt-get install -y \
    openslide-tools \
    g++ \
    gcc \
    libblas-dev \
    liblapack-dev

COPY environment.yml .

RUN conda env create -f environment.yml
RUN conda install -c conda-forge conda-pack
RUN conda-pack --ignore-missing-files -n pathml -o /tmp/env.tar
RUN mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
    rm /tmp/env.tar
RUN /venv/bin/conda-unpack

FROM nvidia/cuda:11.4.0-runtime-ubuntu20.04 AS runtime
# Copy /venv from the previous stage:
COPY --from=build /venv /venv

RUN apt-get update && apt-get install -y \
    openslide-tools \
    g++ \
    gcc \
    libblas-dev \
    liblapack-dev \ 
    libgl1-mesa-glx
# When image is run, run the code with the environment
# activated:
SHELL ["/bin/bash", "-c"]
ENTRYPOINT source /venv/bin/activate && \
    python -c "import pathml; print('success!')"

