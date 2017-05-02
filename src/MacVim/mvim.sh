#!/bin/sh
#
# This shell script passes all its arguments to the binary inside the
# MacVim.app application bundle.  If you make links to this script as view,
# gvim, etc., then it will peek at the name used to call it and set options
# appropriately.
#
# Based on a script by Wout Mertens and suggestions from Laurent Bihanic.  This
# version is the fault of Benji Fisher, 16 May 2005 (with modifications by Nico
# Weber and Bjorn Winckler, Aug 13 2007).
#

# Find Vim executable
if [ -L $0 ]; then
	# readlink -f
	curdir=`pwd -P`
	self_path=$0
	cd `dirname $self_path`
	while [ -L $self_path ]; do
		self_path=`readlink $self_path`
		cd `dirname $self_path`
		self_path=`basename $self_path`
	done
	binary="`pwd -P`/../MacOS/Vim"
	cd $curdir
else
	binary="`dirname "$0"`/../MacOS/Vim"
fi
if ! [ -x $binary ]; then
	echo "Sorry, cannot find Vim executable."
	exit 1
fi

# Next, peek at the name used to invoke this script, and set options
# accordingly.

name="`basename "$0"`"
gui=
opts=

# GUI mode, implies forking
case "$name" in m*|g*|rm*|rg*) gui=true ;; esac

# Logged in over SSH? No gui.
if [ -n "${SSH_CONNECTION}" ]; then
	gui=
fi

# Restricted mode
case "$name" in r*) opts="$opts -Z";; esac

# vimdiff, view, and ex mode
case "$name" in
	*vimdiff)
		opts="$opts -dO"
		;;
	*view)
		opts="$opts -R"
		;;
	*ex)
		opts="$opts -e"
		;;
esac

# Last step:  fire up vim.
# The program should fork by default when started in GUI mode, but it does
# not; we work around this when this script is invoked as "gvim" or "rgview"
# etc., but not when it is invoked as "vim -g".
if [ "$gui" ]; then
	# Note: this isn't perfect, because any error output goes to the
	# terminal instead of the console log.
	# But if you use open instead, you will need to fully qualify the
	# path names for any filenames you specify, which is hard.
	exec "$binary" -g $opts ${1:+"$@"}
else
	exec "$binary" $opts ${1:+"$@"}
fi