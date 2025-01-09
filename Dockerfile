# Please note that in line 178, you need to change the download link to the real download link of cellranger. 注意178行改链接

# Use Ubuntu as the base image
# 使用 Ubuntu 作为基础镜像
FROM ubuntu:latest

# Install essential dependencies
# 安装必要的依赖
RUN apt-get update && apt-get install -y wget tar unzip make gcc g++ git cmake python3 python3-pip python3-venv python3-dev openjdk-17-jdk pipx

# Install dependencies for samtools
# 安装samtools的依赖
RUN apt-get install -y autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev vim
RUN apt-get update && apt-get install -y libncurses5-dev
RUN pipx ensurepath
ENV PATH="/root/.local/bin:$PATH"

# Add a new user 'ubuntu'
# 添加新用户 'ubuntu'
RUN id -u ubuntu &>/dev/null || useradd -m ubuntu

# Install sudo and curl, and grant sudo permissions to the user 'ubuntu'
# 安装 sudo 和 curl，并给予 'ubuntu' 用户 sudo 权限
RUN apt-get update && apt-get install -y sudo curl
RUN adduser ubuntu sudo
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu

USER ubuntu

# Set the working directory
# 设置工作目录
WORKDIR /home/ubuntu

SHELL ["/bin/bash", "-c"]

# Define environment variables
# 定义环境变量
ENV RNA_HOME=/home/ubuntu/workspace/rnaseq \
    RNA_EXT_DATA_DIR=/home/ubuntu/CourseData/RNA_data \
    RNA_DATA_DIR=/home/ubuntu/workspace/rnaseq/data \
    RNA_DATA_TRIM_DIR=/home/ubuntu/workspace/rnaseq/data/trimmed \
    RNA_REFS_DIR=/home/ubuntu/workspace/rnaseq/refs \
    RNA_REF_INDEX=/home/ubuntu/workspace/rnaseq/refs/chr22_with_ERCC92 \
    RNA_REF_FASTA=/home/ubuntu/workspace/rnaseq/refs/chr22_with_ERCC92.fa \
    RNA_REF_GTF=/home/ubuntu/workspace/rnaseq/refs/chr22_with_ERCC92.gtf \
    RNA_ALIGN_DIR=/home/ubuntu/workspace/rnaseq/alignments/hisat2 \
    WORKSPACE=/home/ubuntu/workspace \
    HOME=/home/ubuntu \
    PICARD=/home/ubuntu/bin/picard.jar \
    GATK_REGIONS='-L chr17'

# Set environment variables and create directories. If the link failed, I got a copy in the repository, please check the file bashrc_copy.
# 设置环境变量并创建目录。若链接失效，查看仓库里的文件 bashrc_copy。
RUN cd ~ && \
    wget http://genomedata.org/rnaseq-tutorial/bashrc_copy && \
    mv bashrc_copy ~/.bashrc && \
    echo "export PATH=/home/ubuntu/bin/tophat-2.1.1.Linux_x86_64:\$PATH" >> ~/.bashrc && \
    echo "export PATH=/home/ubuntu/bin/fastp:\$PATH" >> ~/.bashrc && \
    echo "export PATH=/home/ubuntu/sratoolkit.3.0.10-ubuntu64/bin:\$PATH" >> ~/.bashrc && \
    source ~/.bashrc && \
    mkdir -p ~/workspace/rnaseq/

RUN mkdir -p $RNA_HOME/student_tools

# 安装samtools
RUN mkdir -p ~/bin/ && \
    cd ~/bin/ && \
    wget https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 && \
    bunzip2 samtools-1.18.tar.bz2 && \
    tar -xvf samtools-1.18.tar && \
    cd samtools-1.18 && \
    ./configure && \
    make

# 安装bam-readcount
RUN cd ~/bin/ && \
    git clone https://github.com/genome/bam-readcount  && \
    cd bam-readcount && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make

# 安装HISAT2
RUN cd ~/bin/ && \
    wget https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download && \
    mv download hisat2-2.2.1-Linux_x86_64.zip && \
    unzip hisat2-2.2.1-Linux_x86_64.zip && \
    rm hisat2-2.2.1-Linux_x86_64.zip
# 安装StringTie
RUN cd ~/bin/ && \
    wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz && \
    tar -xzvf stringtie-2.2.1.Linux_x86_64.tar.gz && \
    mv stringtie-2.2.1.Linux_x86_64 stringtie-2.2.1
    
# 安装gffcompare
RUN cd ~/bin/ && \
    wget http://ccb.jhu.edu/software/stringtie/dl/gffcompare-0.12.6.Linux_x86_64.tar.gz && \
    tar -xzvf gffcompare-0.12.6.Linux_x86_64.tar.gz

# 安装htseq-count
RUN pipx install HTSeq

# 安装TopHat
RUN cd ~/bin/ && \
    wget http://genomedata.org/rnaseq-tutorial/tophat-2.1.1.Linux_x86_64.tar.gz && \
    tar -zxvf tophat-2.1.1.Linux_x86_64.tar.gz

# 安装kallisto
RUN cd ~/bin/ && \
    wget https://github.com/pachterlab/kallisto/releases/download/v0.44.0/kallisto_linux-v0.44.0.tar.gz && \
    tar -zxvf kallisto_linux-v0.44.0.tar.gz

# 安装FastQC
RUN cd ~/bin/ && \
    wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip && \
    unzip fastqc_v0.12.1.zip

# 安装Fastp
RUN cd ~/bin/ && \
    mkdir fastp && \
    cd fastp && \
    wget http://opengene.org/fastp/fastp && \
    chmod a+x ./fastp

# 安装MultiQC
RUN pipx install multiqc

# 安装Picard
RUN cd ~/bin/ && \
    wget https://github.com/broadinstitute/picard/releases/download/3.1.0/picard.jar

# 安装flexbar
RUN cd ~/bin/ && \
    wget https://github.com/seqan/flexbar/releases/download/v3.5.0/flexbar-3.5.0-linux.tar.gz && \
    tar -zxvf flexbar-3.5.0-linux.tar.gz && \
    echo "LD_LIBRARY_PATH=/home/ubuntu/bin/flexbar-3.5.0-linux:\$LD_LIBRARY_PATH" >> ~/.bashrc && \
    source ~/.bashrc

# 安装RegTools
RUN cd ~/bin/ && \
    git clone https://github.com/griffithlab/regtools  && \
    cd regtools/ && \
    mkdir build && \
    cd build/ && \
    cmake .. && \
    make

# 安装RSeQC
RUN pipx install RSeQC

# 安装bedops
RUN cd ~/bin/ && \
    mkdir bedops_linux_x86_64-v2.4.41 && \
    cd bedops_linux_x86_64-v2.4.41 && \
    wget https://github.com/bedops/bedops/releases/download/v2.4.41/bedops_linux_x86_64-v2.4.41.tar.bz2 && \
    tar -jxvf bedops_linux_x86_64-v2.4.41.tar.bz2

# 安装gtfToGenePred
RUN cd ~/bin/ && \
    mkdir gtfToGenePred && \
    cd gtfToGenePred && \
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred && \
    chmod a+x gtfToGenePred

# 安装genePredToBed
RUN cd ~/bin/ && \
    mkdir genePredToBed && \
    cd genePredToBed && \
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/genePredToBed && \
    chmod a+x genePredToBed

# 安装how_are_we_stranded_here
RUN pipx install how_are_we_stranded_here

# 安装CellRanger
RUN cd ~/bin/ && \
    wget https://xxxxxxxx/cellranger-7.2.0.tar.gz   # change to the real download link
RUN cd ~/bin/ && \
    tar -xzf cellranger-7.2.0.tar.gz


# Return to root user to install R and other system-level packages
# 切换回 root 用户来安装 R 和其他系统级别的包
USER root

# Set timezone and non-interactive mode
# 设置时区和非交互模式
ARG TZ=Asia/Shanghai        # change to your timezone
ARG DEBIAN_FRONTEND=noninteractive

# Install R and its dependencies
# 安装 R 和其依赖
RUN apt-get install --no-install-recommends -y software-properties-common dirmngr && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN apt-get update -qq && apt-get install -y --no-install-recommends r-base  # install R

# Install dependencies for devtools and edgeR
# 为了devtools以及edgeR的安装，需要安装一些依赖
RUN apt-get install -y libxml2-dev build-essential libharfbuzz-dev libfribidi-dev libcairo2-dev libmagick++-dev gfortran libeigen3-dev liblapack-dev libblas-dev

# Set R environment to install packages non-interactively
# 设置 R 环境以非交互式方式安装包
RUN Rscript -e "options(repos = list(CRAN = 'https://cloud.r-project.org/'));install.packages(c('devtools'),dependencies = TRUE)"
RUN Rscript -e "options(repos = list(CRAN = 'https://cloud.r-project.org/'));install.packages(c('dplyr', 'gplots', 'tidyverse'))"

# Install Bioconductor packages
# 安装 Bioconductor 包
RUN Rscript -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager"); BiocManager::install(c("genefilter"),dependencies = TRUE,force = TRUE)'
RUN Rscript -e 'BiocManager::install(c("edgeR","ballgown"),dependencies = TRUE)'
RUN Rscript -e 'BiocManager::install(c("GenomicRanges", "rhdf5", "biomaRt"),dependencies = TRUE,force = TRUE)'

# # 设置 R 环境以非交互式方式安装包，使用 TUNA 镜像源
# RUN Rscript -e "options(repos = list(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));install.packages(c('devtools'),dependencies = TRUE)"
# RUN Rscript -e "options(repos = list(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));install.packages(c('dplyr', 'gplots', 'tidyverse'))"

# # 安装 Bioconductor 包，使用 TUNA 镜像源
# RUN Rscript -e 'options(repos = list(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")); if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager"); BiocManager::install(c("genefilter"),dependencies = TRUE,force = TRUE)'
# RUN Rscript -e 'options(repos = list(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")); BiocManager::install(c("edgeR","ballgown"),dependencies = TRUE)'
# RUN Rscript -e 'options(repos = list(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")); BiocManager::install(c("GenomicRanges", "rhdf5", "biomaRt"),dependencies = TRUE,force = TRUE)'

# Install sleuth
# 安装 sleuth，若安装失败请使用全局代理(clash 开启TUN）。
RUN Rscript -e "BiocManager::install('pachterlab/sleuth')"


ARG DEBIAN_FRONTEND=dialog
# Return to user mode
# 返回用户模式
USER ubuntu

# Set the default command
# 设置默认命令
CMD ["/bin/bash"]


