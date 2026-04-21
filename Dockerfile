FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------
# 1. Dependencias base
# -------------------------------
RUN apt-get update && apt-get install -y \
    nano git make diffutils pkg-config curl ccache clang lld gdb lldb \
    sed gawk python3-venv python3-dev python3-pip \
    libxml2-dev zlib1g-dev doxygen graphviz libdw-dev \
    build-essential clang bison flex perl python3 \
    default-jre ca-certificates \
    libqt5gui5 libqt5opengl5-dev libqt5svg5-dev \
    qt6-base-dev qt6-base-dev-tools qmake6 libqt6svg6 \
    libqt6gui6 libqt6opengl6-dev \
    qt6-wayland libwebkit2gtk-4.1-0 libgl1-mesa-dev libglu1-mesa-dev \
    libtk8.6 blt xdg-utils libopenscenegraph-dev \
    libgl1-mesa-dri libgl1-mesa-glx mesa-utils libosmesa6 \
    nemiver mpi-default-dev \
    libfox-1.6-dev libgdal-dev libproj-dev libxerces-c-dev \
    cmake swig \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2. Python libs (OMNeT++)
# -------------------------------
RUN pip3 install --upgrade pip setuptools && \
    pip3 install \
    "packaging>=23.0.0" \
    "matplotlib>=3.5.2,<4.0.0" \
    "numpy>=1.18.0,<3.0.0" \
    "pandas>=1.0.0,<3.0.0" \
    "scipy>=1.0.0,<2.0.0" \
    ipython posix_ipc wheel opp_env websocket-server

# -------------------------------
# 3. SUMO DESDE GITHUB (COMPLETO)
# -------------------------------
RUN git clone https://github.com/eclipse/sumo.git /opt/sumo

WORKDIR /opt/sumo
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

# -------------------------------
# 4. Variables SUMO
# -------------------------------
ENV SUMO_HOME=/opt/sumo
ENV PATH=$SUMO_HOME/bin:$PATH
ENV PYTHONPATH=$SUMO_HOME/tools

# -------------------------------
# 5. Evitar errores xdg
# -------------------------------
RUN ln -sf /bin/true /usr/local/bin/xdg-desktop-menu && \
    ln -sf /bin/true /usr/local/bin/xdg-icon-resource && \
    ln -sf /bin/true /usr/local/bin/xdg-mime

# -------------------------------
# 6. Crear usuario NO ROOT
# -------------------------------
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID user && \
    useradd -m -u $USER_ID -g user -s /bin/bash user

# -------------------------------
# 7. Workspace
# -------------------------------
WORKDIR /home/user/omnet

RUN echo 'export PYTHONPATH=$SUMO_HOME/tools' >> /home/user/.bashrc && \
    echo 'if [ -d "/home/user/omnet/.opp_env" ]; then source /home/user/omnet/.opp_env/bin/activate; fi' >> /home/user/.bashrc

USER user

CMD ["/bin/bash"]
