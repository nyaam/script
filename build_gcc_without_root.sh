#! /bin/bash
set -e
#-----------------------------------------------------------------------------
# This script will download packages, configure, build and install a GCC.
# Customize the variables (GCC_VERSION, MPFR_VERSION, etc.) before running.
#-----------------------------------------------------------------------------

# Path where to install without root
LOCAL_PATH=/home/username/local


PARALLEL_MAKE=-j32
GCC_VERSION=gcc-6.3.0
GCC_VERSION=gcc-5.4.0
MPFR_VERSION=mpfr-3.1.5
GMP_VERSION=gmp-6.1.2
MPC_VERSION=mpc-1.0.3


# Creat a directory
if [ ! -f gcc ]
then
  mkdir -p gcc
else
  rm -rf gcc
fi
cd gcc/


# Download packages
export http_proxy=$HTTP_PROXY https_proxy=$HTTP_PROXY ftp_proxy=$HTTP_PROXY
wget -nc https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz

# Extract Packages
echo "Extracting tar files ..."
for f in *.tar*; do tar xfk $f; done

# Step 1. Install GMP
echo "Step 1. Installing GMP ..."
cd $GMP_VERSION
./configure --prefix=$LOCAL_PATH/$GMP_VERSION --enable-cxx
nice -n 19 time make $PARALLEL_MAKE
make install && make check
cd ..

# Step 2. Install MPFR
echo "Step 2. Installing MPFR ..."
cd $MPFR_VERSION
./configure --prefix=$LOCAL_PATH/$MPFR_VERSION --with-gmp=$LOCAL_PATH/$GMP_VERSION 
nice -n 19 time make $PARALLEL_MAKE
make install && make check
cd ..

# Step 3. Install MPC
echo "Step 3. Installing MPC ..."
cd $MPC_VERSION
LD_LIBRARY_PATH=$LOCAL_PATH/$GMP_VERSION/lib:$LOCAL_PATH/$MPFR_VERSION/lib ./configure --prefix=$LOCAL_PATH/$MPC_VERSION --with-gmp=$LOCAL_PATH/$GMP_VERSION --with-mpfr=$LOCAL_PATH/$MPFR_VERSION
LD_LIBRARY_PATH=$LOCAL_PATH/$GMP_VERSION/lib:$LOCAL_PATH/$MPFR_VERSION/lib nice -n 19 time make $PARALLEL_MAKE
make install && make check
cd ..

# Step 4. Install GCC
echo "Step 4. Installing GCC ..."
cd $GCC_VERSION
mkdir -p build && cd build
LD_LIBRARY_PATH=$LOCAL_PATH/$GMP_VERSION/lib:$LOCAL_PATH/$MPFR_VERSION/lib:$LOCAL_PATH/$MPC_VERSION/lib ../configure --prefix=$LOCAL_PATH/$GCC_VERSION --with-gmp=$LOCAL_PATH/$GMP_VERSION --with-mpfr=$LOCAL_PATH/$MPFR_VERSION --with-mpc=$LOCAL_PATH/$MPC_VERSION --disable-multilib --enable-languages=c,c++ --enable-libgomp
LD_LIBRARY_PATH=$LOCAL_PATH/$GMP_VERSION/lib:$LOCAL_PATH/$MPFR_VERSION/lib:$LOCAL_PATH/$MPC_VERSION/lib nice -n 19 time make $PARALLEL_MAKE
make install && make check
cd ..

# echo $MACHTYPE
#$LOCAL_PATH/$GCC_VERSION/lib64 is correct on x86_64; it may need to be replaced with $LOCAL_PATH/$GCC_VERSION/lib on other platforms.
export LD_LIBRARY_PATH=$LOCAL_PATH/$GMP_VERSION/lib:$LOCAL_PATH/$MPFR_VERSION/lib:$LOCAL_PATH/$MPC_VERSION/lib:$LOCAL_PATH/$GCC_VERSION/lib64
export PATH=$LOCAL_PATH/$GCC_VERSION/bin:$PATH
