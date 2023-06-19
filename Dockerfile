FROM ubuntu:20.04


# Install packaged dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
        autotools-dev \
        build-essential \
        cmake \
        curl \
        gfortran \
        git \
        g++ \
        libatlas-base-dev \
        libavcodec-dev \
        libavformat-dev \
        libbz2-dev \
        libdc1394-22-dev \
        libgl1-mesa-dev \
        libglib2.0-dev \
        libgtk-3-dev \
        libicu-dev \
        libjpeg-dev \
        libpng-dev \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libtiff-dev \
        libv4l-dev \
        libxvidcore-dev \
        libx264-dev \
        openexr \
        pkg-config \
        python-dev \
        python3-dev \
        python3-numpy \
        zip \
        zlib1g-dev


# Install Boost (1.62.0)
WORKDIR /opt
SHELL ["/bin/bash", "-c"]
RUN curl -o boost_1_62_0.tar.gz -L https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz/download
RUN tar xzvf boost_1_62_0.tar.gz
RUN rm boost_1_62_0.tar.gz
WORKDIR /opt/boost_1_62_0/
RUN ./bootstrap.sh --prefix=/usr/local
RUN ./b2 --with=all -j $(nproc) install 
RUN sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf'
RUN ldconfig


# Install Open Scene Graph (3.4.1)
WORKDIR /opt
RUN git clone https://github.com/openscenegraph/osg
WORKDIR /opt/osg
RUN git checkout tags/OpenSceneGraph-3.4.1
WORKDIR /opt/osg/build
RUN cmake ..
RUN make -j $(nproc)
RUN make install
ENV LD_LIBRARY_PATH="/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH"
ENV OPENTHREADS_INC_DIR="/usr/local/include"
ENV OPENTHREADS_LIB_DIR="/usr/local/lib64:/usr/local/lib"
ENV PATH="$OPENTHREADS_LIB_DIR:$PATH"


# Install OpenCV (3.2.0)
WORKDIR /opt/opencv_build
RUN git clone https://github.com/opencv/opencv_contrib.git
WORKDIR /opt/opencv_build/opencv_contrib
RUN git checkout 3.2.0
WORKDIR /opt/opencv_build
RUN git clone https://github.com/opencv/opencv.git
WORKDIR /opt/opencv_build/opencv
RUN git checkout 3.2.0
COPY patches/cap_ffmpeg_impl.patch .
RUN patch modules/videoio/src/cap_ffmpeg_impl.hpp cap_ffmpeg_impl.patch
WORKDIR /opt/opencv_build/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D BUILD_opencv_python3=OFF \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_build/opencv_contrib/modules \
        ..
RUN make VERBOSE=1 -j $(nproc)
RUN make install


# Install miniconda
WORKDIR /opt
RUN curl -o miniconda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN chmod +x miniconda.sh
RUN ./miniconda.sh -b -p /opt/conda
RUN rm miniconda.sh
ENV PATH=/opt/conda/bin:$PATH
RUN conda init bash


# Create conda environment for weather augmentation
RUN conda create --name py36_weatheraugment python=3.6
SHELL ["conda", "run", "-n", "py36_weatheraugment", "/bin/bash", "-c"]
RUN pip install \
        glob2==0.7 \
        imageio==2.9.0 \
        imutils==0.5.4 \
        matplotlib==3.3.4 \
        natsort==7.1.1 \
        numpy==1.19.2 \
        opencv-python==4.7.0.72 \
        pexpect==4.8.0 \
        pillow==8.3.1 \
        pyclipper==1.3.0.post3 \
        scikit-image==0.17.2 \
        scikit-learn==0.24.2 \
        scipy==1.5.2 \
        tqdm==4.63.0


# Install Rain Streak DB
WORKDIR /opt/rain-rendering/3rdparty
RUN curl -o databases.zip -L https://www.cs.columbia.edu/CAVE/databases/rain_streak_db/databases.zip
RUN unzip databases.zip -d rainstreakdb
RUN rm databases.zip


# Copy in rain-rendering
RUN mkdir -p /opt/rain-rendering
COPY 3rdparty /opt/rain-rendering/3rdparty
COPY common /opt/rain-rendering/common
COPY config /opt/rain-rendering/config
COPY LICENSE /opt/rian-rendering/LICENSE
COPY *.py /opt/rain-rendering/
COPY README.md /opt/rain-rendering/README.md
COPY scripts /opt/rain-rendering/scripts
COPY tools /opt/rain-rendering/tools


# Set default command and working directory
WORKDIR /opt/rain-rendering/
VOLUME /opt/rain-rendering/data/
RUN echo "conda activate py36_weatheraugment" >> ~/.bashrc
CMD ["/bin/bash"]