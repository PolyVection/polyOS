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

find $build_workspace_dir/tmp/deploy/images -name 'core-image*' -delete 2>/dev/null
find $build_workspace_dir/tmp/deploy/images -name 'sim*.tgz' -delete 2>/dev/null

if [ -e FAILED_SYSROOT ]; then
    echo "Purging tmp/ directory due to previous failure in this workspace"
    rm -rf tmp
    rm -f FAILED_SYSROOT
fi

bitbake $EXTRA_BITBAKE_FLAGS $target 2>&1 | tee bitbake.log
build_exit_code=${PIPESTATUS[0]}

if grep -q "is trying to install files into a shared area when those files already exist" bitbake.log; then
    # If we got warning from overwriting a file in sysroot, we want that
    # to be a hard failure.
    echo "ERROR: build overwrote existing files in sysroot"
    touch FAILED_SYSROOT
    build_exit_code=1
fi

if [ $build_exit_code -eq 0 ]; then
    if [ "$cleanup_after" -ne 0 ]; then
	    echo "Cleaning workdirs..."
	    cleanup-workdir
    fi
fi

if [ -n "$sstate_install_dir" ]
then
    echo "Copying shared state to ${sstate_install_dir}."
    #---------------------------------------------------------------------------
    # Starting with Yocto 1.3, sstate-cache contains directories named after the
    # first two letters of the hash.  Furthermore, native packages are put into
    # OS-named directories before being put into such hash-named directories.
    # We want to preserve this structure to improve the performance of our cache
    # and avoid any limits on the number of files in a directory.  (No modern FS
    # has such limits, but if we use NFS on our filers, such a limit does
    # exist.)
    #
    # Because of this, we must cd into the sstate-cache before running the find
    # command.  Otherwise, the find would try to create a directory called
    # 'sstate-cache' on the mirror, which is something we don't want.
    #---------------------------------------------------------------------------

    if [ -d sstate-cache ]; then
	cd sstate-cache

	find . -type d -exec chmod g+ws \{} \;
	rsync --ignore-existing -prL . ${sstate_install_dir}
	cd ..
	rm sstate-cache -rf
	echo "Finished copying shared state to ${sstate_install_dir}."
    fi
fi

#---------------------------------------------------------------------------
# Put all logs at the top level of the build-bundle.
#---------------------------------------------------------------------------

cd ${build_bundle_dir}
cp .gitmodules layer-info.log
git submodule status >> layer-info.log
git log -1 --pretty=oneline | awk '{print $1}' > bundle-rev.log

if [ $build_exit_code -ne 0 ]
then
    fail_dirs="buildstats pkgdata sstate-control stamps"
    if [ -n "$CAPTURE_FAILING_SYSROOTS" ]; then
	    fail_dirs="$fail_dirs sysroots"
    fi
    if [ -n "$CAPTURE_ALL_WORKDIRS" ]; then
	    fail_dirs="$fail_dirs work"
    else
	    failed_recipes=$(mktemp)
	    gawk '/ERROR: Logfile of failure/{print $7}' ${build_workspace_dir}/bitbake.log > $failed_recipes
	    while read logfile; do
		    workdir=$(dirname $(dirname $logfile))
		    workdir=$(echo $workdir | sed "s|$build_workspace_dir/tmp/||")
		    fail_dirs="$fail_dirs $workdir"
	    done < $failed_recipes
	    rm $failed_recipes
    fi

    for d in $fail_dirs; do
	    mkdir -p ${build_workspace_dir}/tmp/$d
    done
    tar -czf ${build_workspace_dir}/fail.tgz -C ${build_workspace_dir}/tmp $fail_dirs
    tar_exit_code="$?"

    if [ $tar_exit_code -ne 0 ]; then
	    echo "ERROR: tar failed"
	    rm ${build_workspace_dir}/fail.tgz
    fi
else
    # Get rid of downloads to save space
    rm downloads -rf
fi

exit $build_exit_code
