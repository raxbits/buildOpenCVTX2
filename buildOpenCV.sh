#!/bin/bash
# License: MIT. See license file in root directory
# Copyright(c) JetsonHacks (2017)
# Extending for python 2/3 builds, on demand
# Modified/Extended: Ramin Ranjbar - Raxbits@gmail.com

main_dir=$HOME
cv_dir='$main_dir/opencv'
cv_extra_dir='cv_dir/opencv_extra'

usage="
$(basename "$0") ======> Builds OpenCV for NVIDIA TX systems.
Available OPTIONS:
    -h  show this help text
    -py2 Builds for python2 
    -py3 Builds for python3
    "


function get_deps
{

	sudo apt-get install -y \
    libglew-dev \
    libtiff5-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng12-dev \
    libjasper-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libpostproc-dev \
    libswscale-dev \
    libeigen3-dev \
    libtbb-dev \
    libgtk2.0-dev \
    cmake \
    pkg-config

}

function build_helper
{
	case "$1" in 
		py2)
			cmake \
		    -DCMAKE_BUILD_TYPE=Release \
		    -DCMAKE_INSTALL_PREFIX=/usr \
		    -DBUILD_PNG=OFF \
		    -DBUILD_TIFF=OFF \
		    -DBUILD_TBB=OFF \
		    -DBUILD_JPEG=OFF \
		    -DBUILD_JASPER=OFF \
		    -DBUILD_ZLIB=OFF \
		    -DBUILD_EXAMPLES=ON \
		    -DBUILD_opencv_java=OFF \
		    -DBUILD_opencv_python2=ON \
		    -DBUILD_opencv_python3=OFF \
		    -DENABLE_PRECOMPILED_HEADERS=OFF \
		    -DWITH_OPENCL=OFF \
		    -DWITH_OPENMP=OFF \
		    -DWITH_FFMPEG=ON \
		    -DWITH_GSTREAMER=ON \
		    -DWITH_GSTREAMER_0_10=OFF \
		    -DWITH_CUDA=ON \
		    -DWITH_GTK=ON \
		    -DWITH_VTK=OFF \
		    -DWITH_TBB=ON \
		    -DWITH_1394=OFF \
		    -DWITH_OPENEXR=OFF \
		    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 \
		    -DCUDA_ARCH_BIN=6.2 \
		    -DCUDA_ARCH_PTX="" \
		    -DINSTALL_C_EXAMPLES=ON \
		    -DINSTALL_TESTS=ON \
		    -DOPENCV_TEST_DATA_PATH=../opencv_extra/testdata \
		    ../
		    exit
		    ;;
		py3)
			cmake \
		    -DCMAKE_BUILD_TYPE=Release \
		    -DCMAKE_INSTALL_PREFIX=/usr \
		    -DBUILD_PNG=OFF \
		    -DBUILD_TIFF=OFF \
		    -DBUILD_TBB=OFF \
		    -DBUILD_JPEG=OFF \
		    -DBUILD_JASPER=OFF \
		    -DBUILD_ZLIB=OFF \
		    -DBUILD_EXAMPLES=ON \
		    -DBUILD_opencv_java=OFF \
		    -DBUILD_opencv_python2=OFF \
		    -DBUILD_opencv_python3=ON \
		    -DENABLE_PRECOMPILED_HEADERS=OFF \
		    -DWITH_OPENCL=OFF \
		    -DWITH_OPENMP=OFF \
		    -DWITH_FFMPEG=ON \
		    -DWITH_GSTREAMER=ON \
		    -DWITH_GSTREAMER_0_10=OFF \
		    -DWITH_CUDA=ON \
		    -DWITH_GTK=ON \
		    -DWITH_VTK=OFF \
		    -DWITH_TBB=ON \
		    -DWITH_1394=OFF \
		    -DWITH_OPENEXR=OFF \
		    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 \
		    -DCUDA_ARCH_BIN=6.2 \
		    -DCUDA_ARCH_PTX="" \
		    -DINSTALL_C_EXAMPLES=ON \
		    -DINSTALL_TESTS=ON \
		    -DOPENCV_TEST_DATA_PATH=../opencv_extra/testdata \
		    ../
		    exit
		    ;;
	esac

	# Consider using all 6 cores; $ sudo nvpmodel -m 2 or $ sudo nvpmodel -m 0
	make -j$(nproc)

}

function build_cv
{
	get_deps #install general dependencies
	case "$1" in
		l | legacy)
			py2_subroutine
			exit
			;;
		n | new) 
			py3_subroutine
			exit
			;;
	esac

}

function py2_subroutine
{
	sudo apt-get install -y python-dev python-numpy python-py python-pytest -y
	sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev 
	pushd .
	cd $main_dir
	get_cv && get_cv_extras
	mkdir $cv_dir/build && cd $cv_dir/build 
	build_helper 'py2'
	#sudo make install -j$(nproc)
	echo -e '\n\n =====> OpenCV is installed for python2\n\n'
	popd 
}

function py3_subroutine
{
	sudo apt-get install -y python3-dev python3-numpy python3-py python3-pytest -y
	sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev 
	pushd .
	cd $main_dir
	get_cv && get_cv_extras
	mkdir $cv_dir/build && cd $cv_dir/build 
	build_helper 'py3'
	#sudo make install -j$(nproc)
	echo -e '\n\n =====> OpenCV is installed for python3\n\n'
	popd 
}

function get_cv
{
	git clone https://github.com/opencv/opencv.git
	cd opencv
	git checkout -b v3.3.0 3.3.0
}

function get_cv_extras
{
	cd $HOME
	git clone https://github.com/opencv/opencv_extra.git
	cd opencv_extra
	git checkout -b v3.3.0 3.3.0
}

while getopts ":helplegacynew" option; do
  case "$option" in
	h | help)
		echo -e '$usage'
		exit 
		;;
	l | legacy)
		build_cv "$option"
		exit 
		;;
	n | new)
		build_cv "$option"
		exit 
		;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       	exit 1
       ;;
   \?) printf "Unknown Option -%s" "$OPTARG" >&2
       echo "$usage" >&2
       	exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

