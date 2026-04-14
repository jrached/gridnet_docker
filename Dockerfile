FROM nvcr.io/nvidia/l4t-pytorch:r35.1.0-pth1.11-py3

ENV DEBIAN_FRONTEND=noninteractive

# ---------------- CUDA ----------------
#ENV CUDA_HOME=/usr/local/cuda
#ENV PATH=${CUDA_HOME}/bin:${PATH}
#ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# ---------------- Base OS ----------------
RUN apt-get update -o Acquire::ForceIPv4=true && apt-get install -y \
    curl \
    gnupg2 \
    locales \
    lsb-release \
    ca-certificates \
    software-properties-common \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# ---------------- Locale ----------------
RUN locale-gen en_US en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ---------------- ROS 2 Foxy ----------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu focal main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update -o Acquire::ForceIPv4=true && apt-get install -y \
    ros-foxy-ros-base \
    ros-foxy-rmw-cyclonedds-cpp \
    python3 \
    python3-dev \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# PointPillars expects `python`, not just `python3`
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ---------------- Python tooling (PINNED) ----------------
#RUN python3 -m pip install --upgrade \
#    pip==23.3.2 \
#    setuptools==58.0.4 \
#    wheel==0.45.1

# ---------------- PyTorch (CUDA 11.1, Python 3.8) ----------------
#RUN python3 -m pip install \
#    torch==1.8.2+cu111 \
#    torchvision==0.9.2+cu111 \
#    torchaudio==0.8.2 \
#    --extra-index-url https://download.pytorch.org/whl/lts/1.8/cu111

# ---------------- Critical legacy deps ----------------
# These versions are REQUIRED for PointPillars-era Open3D
# Remove distutils-installed PyYAML from apt (conflicts with pip)

RUN python3 -m pip install \
    PyYAML==5.4.1 \
    --ignore-installed \
    --no-cache-dir

# ---- Open3D (compatible version) ----
RUN apt-get update && apt-get install -y libgl1 && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install \
    open3d==0.14.1 \
    --no-cache-dir

# ---- FORCE legacy NumPy + Numba AFTER ----
#RUN python3 -m pip install \
#    numpy==1.19.5 \
#    llvmlite==0.31.0 \
#    numba==0.48.0 \
#    --force-reinstall \
#    --no-deps \
#    --no-cache-dir

RUN python3 -m pip install \
    tqdm==4.62.3 \
    opencv-python==4.5.5.62 \
    --no-cache-dir

# ---------------- PointPillars (BUILD INSIDE CONTAINER) ----------------
COPY Volume/PointPillars /opt/PointPillars
WORKDIR /opt/PointPillars

# Build CUDA extensions against container glibc + CUDA
#ENV TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.7"
ENV TORCH_CUDA_ARCH_LIST="8.7"
RUN python3 setup.py build_ext --inplace && \
    python3 -m pip install . --no-cache-dir

# ---------------- ROS setup ----------------
RUN rosdep init && rosdep update
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc

# -------- Install Compatible Matplotlib and Pands -------------
# ---- Fix pandas + matplotlib for NumPy 1.19.5 ----
#RUN python3 -m pip uninstall -y pandas matplotlib && \
#    python3 -m pip install \
#        pandas==1.1.5 \
#        matplotlib==3.3.4 \
#        --no-cache-dir

RUN python3 -m pip install \ 
    pandas \ 
    matplotlib \ 
    --no-cache-dir 

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV ROS_DOMAIN_ID=0

WORKDIR /root
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"] 

