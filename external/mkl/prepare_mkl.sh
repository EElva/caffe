#!/bin/sh

# MKL
DST=`dirname $0`
SET_ENV_SCRIPT=$DST/"set_env_up.sh"
# TODO: For ICC use intel for GCC use gnu 
LOCALMKL=`find $DST -name libmkldnn_gnu.so`   # name of MKL SDL lib 
MKLURL="http://TheBestOFIntel.org/MklDnn.tgz" # TODO: Adjust accordingly

# Check if MKL_ROOT is set if positive then set one will be used..
if [ -z $MKLROOT ]; then
  # ..if MKLROOT is not set then check if we have MKL downloaded..
  if [ -z $LOCALMKL ] || [ ! -f $LOCALMKL ]; then
    #...If it is not then downloaded and unpacked
    #wget --no-check-certificate $MKLURL  # FINAL
    # TODO: make it pretty, hash progress print what it does actually eg. dopwnloading unpacking
    cp /home/jczaja/MKL_SELFCONTAINED/mkldnn_lnx_2017.0.0.20160709.1.tgz $DST     # TMP
    tar -xzf $DST/mkldnn_lnx*.tgz
    LOCALMKL=`find $DST -name libmkldnn_gnu.so`   # name of MKL SDL lib 
  fi

  # set MKL env vars are to be done via generated script
  # this will help us export MKL env to existing shell
  
  MKLROOT=$PWD/`echo $LOCALMKL | sed -e 's/lib.*$//'`

  echo '#!/bin/sh' > $SET_ENV_SCRIPT
  echo "export MKLROOT=$MKLROOT" >> $SET_ENV_SCRIPT
  echo "export LD_LIBRARY_PATH=$MKLROOT/lib:\${LD_LIBRARY_PATH}" >> $SET_ENV_SCRIPT
  echo "export CPATH=\${CPATH}:${MKLROOT}/include/" >> $SET_ENV_SCRIPT
  chmod 755 $SET_ENV_SCRIPT
fi

# Check what MKL lib we have in MKLROOT
if [ -z `find $MKLROOT -name libmkl_rt.so -print -quit` ]; then
  LIBRARIES=`basename $LOCALMKL | sed -e 's/^.*lib//' | sed -e 's/\.so.*$//'` 
else
  LIBRARIES="mkl_rt"
fi 


# return value to calling script (Makefile,cmake)
echo $MKLROOT $LIBRARIES
