#!/bin/bash
# submit jobs
cluster=$1
case "$cluster" in
roger)
	demdir="$HOME/scratch/taudem/data"
	mpiclause="mpirun"
	nplists=("160 80 40 20" "500 400 300 200 100 60 40") 
	scheduler=pbs
	taudem1=/sw/geosoft/TauDEM/bin
	taudem2=/gpfs/largeblockFS/scratch/taudem/TauDEM-5.3.1
	ppn=20
	wtime="48:00:00"
	rdir=/gpfs/largeblockFS/scratch/gisolve/taudem/test
	;;
stampede)
	demdir="$WORK/taudem53test/data"
	mpiclause="ibrun"
	nplists=("256 128 64 32 16" "1024 512 256 128 64") 
	scheduler=slurm
	taudem1=$WORK/TauDEM/build/bin
	taudem2=$WORK/TauDEM-5.3.1
	ppn=16
	wtime="48:00:00"
	rdir=$WORK/taudem53test/test
	;;
*)
	echo "Usage: $0 roger|stampede"
	exit 1
esac
dlist=("Yellowstone/YellowMF" "Chesapeake/ches10mMF")
if [ ! -d $rdir ]; then
	mkdir -p $rdir
fi

for testcase in 0 1
do

nplist=${nplists[$testcase]}
d=${dlist[$testcase]}
dem1=$demdir/$d
d2=`echo "$d" | awk -F\/ '{print $1}'`
dem2=$demdir/$d2.vrt

for np in $nplist
do
###############
jfile="$cluster.$np.$d2.$scheduler"
echo "creating $jfile ..."
n=`expr $np \/ $ppn`
j="$np.$d2"
wdir=$rdir/$j
#[ -d $wdir ] && rm -fr $wdir/*
[ ! -d $wdir ] && mkdir -p $wdir
jout=$wdir/$j.out
jerr=$wdir/$j.err
# job sub header
sed -e "s|__NAME__|$j|" \
    -e "s|__STDERR__|$jerr|" \
    -e "s|__STDOUT__|$jout|" \
    -e "s|__N__|$np|" \
    -e "s|__NN__|$n|" \
    -e "s|__PPN__|$ppn|" \
    -e "s|__T__|$wtime|" \
    _$scheduler.template > $jfile

# work dir
echo "cd $wdir" >> $jfile
# exec
if [ "$mpiclause" == "mpirun" ]; then
	mpiclause="$mpiclause -np $np "
fi
echo "`pwd`/taudemrun.sh $d2 \"$mpiclause\" $taudem1 $dem1 $taudem2 $dem2" >> $jfile 
###############
done

done
