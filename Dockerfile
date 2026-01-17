FROM jmgirard/audio-whisper:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    cifs-utils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mnt/datasets
RUN mkdir -p /mnt/projects

RUN Rscript -e "install.packages('getPass', repos='https://cloud.r-project.org')"

COPY lab_utils.R /usr/local/lib/R/site-library/lab_utils.R
RUN echo "source('/usr/local/lib/R/site-library/lab_utils.R')" >> /usr/local/lib/R/etc/Rprofile.site