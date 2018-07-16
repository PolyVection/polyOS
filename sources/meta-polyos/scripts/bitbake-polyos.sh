#!/bin/bash

my_dir="$(dirname $0)/../.."
build_bundle_dir=$(dirname $(readlink -f $my_dir))
echo "my_dir = '${my_dir}'"
echo "build_bundle_dir = '${build_bundle_dir}'"
#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------

usage()
{
    cat<<EOF 
    
Usage: $0 [options] < -t <target> | -s >

Ensures a yocto workspace is configured, then builds the specified target.

Options:
 
  -t <target>  :  The thing (package, image, whatever) you want to build.
                  Optional only if you throw '-s'.

  -d <dir>     :  Use this directory for the build-bundle.  You may supply
                  an empty or non-existent directory or a pre-populated 
                  build-bundle.  If not specified, you'll get a temp-named 
                  directory instead.
                  
  -w <dir>     :  Use this directory for the build workspace.  You may supply
                  an empty or non-existent directory or a pre-populated 
                  workspace.  If not specified, the directory will be called
                  'build' and placed under the build-bundle.
                  
  -a <packages>:  Comma-separated packages to build using AUTOREV as the SRCREV.

  -i <dir>     :  Install sstate tarballs to the specified directory.
                  (Usually, this directory will be an sstate mirror.)

  -c           :  Run cleanup-workdir after a successful build

  -h           :  This usage message.

EOF
    exit 1

}

#-------------------------------------------------------------------------------
# Option Parsing
#-------------------------------------------------------------------------------

build_bundle_dir=""
sstate_install_dir=""
cleanup_after=0

while getopts ':t:d:w:l:a:i:o:f:srhcv' opt
do
  case $opt in
      t) target="$OPTARG";;
      d) build_bundle_dir="$OPTARG";;
      w) build_workspace_dir="$OPTARG";;
      a) head_pkgs="-a $OPTARG";;
      i) sstate_install_dir="$OPTARG";;
      c) cleanup_after=1;;
      h) usage;;
      *) echo "WARN: '-${OPTARG}' isn't a valid option; I'm ignoring it.";;
  esac
done
shift `expr $OPTIND - 1`

if [ -z "$target" ]
then
    echo "FATAL: No target specified."
    exit 2
fi

#-------------------------------------------------------------------------------
# Real work starts here
#-------------------------------------------------------------------------------

if [ -z "$build_bundle_dir" ]
then
    build_bundle_dir=$(dirname $(readlink -f $my_dir))
fi

#-------------------------------------------------------------------------------
# Ensure build_bundle_dir is always an absolute path, regardless of whether
# you supplied one or not.  The call to configure-workspace can fail if you
# supply a relative path to '-d'.
#-------------------------------------------------------------------------------

build_bundle_dir=$(readlink -f $build_bundle_dir)

init_build_env=${build_bundle_dir}/sources/poky/oe-init-build-env

if [ ! -f $init_build_env ]
then
    echo "FATAL: Couldn't find $init_build_env."
    exit 3
fi

cd $build_bundle_dir

if [ -z "$build_workspace_dir" ]
then
    build_workspace_dir="build"
fi

build_workspace_dir=$(readlink -f $build_workspace_dir)

#-------------------------------------------------------------------------------
# This 'source' call change us into $build_workspace_dir.
#-------------------------------------------------------------------------------

source $init_build_env $build_workspace_dir

if [ -e FAILED_SYSROOT ]; then
    echo "Purging tmp/ directory due to previous failure in this workspace"
    rm -rf tmp
    rm -f FAILED_SYSROOT
fi

bitbake $EXTRA_BITBAKE_FLAGS $target 2>&1 | tee bitbake.log
build_exit_code=${PIPESTATUS[0]}

if [ $build_exit_code -eq 0 ]; then
    polyos_version=grep "DISTRO_VERSION =" ${build_bundle_dir}/sources/meta-polyvection/conf/distro/polyos.conf | awk '{print $3}' | sed s/\"//g
    mkdir ${build_bundle_dir}/release
    mkdir ${build_bundle_dir}/release/polyos_version-(build ${$BUILD_NUMBER})
    cp $build_workspace_dir/tmp/deploy/images/voltastream/_PolyOS_release/polyos_version/* ${build_bundle_dir}/release/polyos_version-(build ${$BUILD_NUMBER})
fi

#---------------------------------------------------------------------------
# Put all logs at the top level of the build-bundle.
#---------------------------------------------------------------------------

cd ${build_bundle_dir}
cp .gitmodules layer-info.log
git submodule status >> layer-info.log
git log -1 --pretty=oneline | awk '{print $1}' > bundle-rev.log

exit $build_exit_code
