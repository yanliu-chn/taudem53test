#!/bin/bash
# workflow execution script
# Usage: taudemrun.sh testname mpi_clause taudem1 dem1 taudem2 dem2

testname="$1"
testname1="${testname}1"
testname2="${testname}2"
mpiclause="$2"
taudem1="$3" # 5.0MF
dem1="$4" # dem dir
taudem2="$5" # 5.3+
dem2="$6" # vrt
log="./run.log"

touch .start
echo "======================================================="
echo "step: pitremove"
T1=`date +%s`
${mpiclause} ${taudem1}/pitremove  -z ${dem1}   -fel ./${testname1}fel  -mf 1 1
T2=`date +%s`
gdalbuildvrt ./${testname1}fel.vrt ./${testname1}fel/*.tif
gdal_translate -of GTiff ./${testname1}fel.vrt ./${testname1}fel.tif
T3=`date +%s`
echo "###1 pitremove `expr $T2 \- $T1` `expr $T3 \- $T2` `expr $T3 \- $T1`"
T1=`date +%s`
${mpiclause} ${taudem2}/pitremove  -z ${dem2}   -fel ./${testname2}fel.tif
T2=`date +%s`
echo "###2 pitremove `expr $T2 \- $T1` "

echo "======================================================="
echo "step: d8flowdir"
T1=`date +%s`
${mpiclause} ${taudem1}/d8flowdir  -fel ./${testname1}fel  -p ./${testname1}p -sd8 ./${testname1}sd8  -mf 1 1
T2=`date +%s`
gdalbuildvrt ./${testname1}p.vrt ./${testname1}p/*.tif
gdal_translate -of GTiff ./${testname1}p.vrt ./${testname1}p.tif
gdalbuildvrt ./${testname1}sd8.vrt ./${testname1}sd8/*.tif
gdal_translate -of GTiff ./${testname1}sd8.vrt ./${testname1}sd8.tif
T3=`date +%s`
echo "###1 d8flowdir `expr $T2 \- $T1` `expr $T3 \- $T2` `expr $T3 \- $T1`"
T1=`date +%s`
${mpiclause} ${taudem2}/d8flowdir  -fel ./${testname2}fel.tif  -p ./${testname2}p.tif -sd8 ./${testname2}sd8.tif
T2=`date +%s`
echo "###2 d8flowdir `expr $T2 \- $T1` "


echo "======================================================="
echo "step: aread8"
T1=`date +%s`
${mpiclause} ${taudem1}/aread8  -p ./${testname1}p  -ad8 ./${testname1}ad8o  -mf 1 1
T2=`date +%s`
gdalbuildvrt ./${testname1}ad8o.vrt ./${testname1}ad8o/*.tif
gdal_translate -of GTiff ./${testname1}ad8o.vrt ./${testname1}ad8o.tif
T3=`date +%s`
echo "###1 aread8 `expr $T2 \- $T1` `expr $T3 \- $T2` `expr $T3 \- $T1`"
T1=`date +%s`
${mpiclause} ${taudem2}/aread8  -p ./${testname2}p.tif  -ad8 ./${testname2}ad8o.tif
T2=`date +%s`
echo "###2 aread8 `expr $T2 \- $T1` "


echo "======================================================="
echo "step: threshold"
T1=`date +%s`
${mpiclause} ${taudem1}/threshold -thresh 300  -ssa ./${testname1}ad8o  -src ./${testname1}src  -mf 1 1
T2=`date +%s`
gdalbuildvrt ./${testname1}src.vrt ./${testname1}src/*.tif
gdal_translate -of GTiff ./${testname1}src.vrt ./${testname1}src.tif
T3=`date +%s`
echo "###1 threshold `expr $T2 \- $T1` `expr $T3 \- $T2` `expr $T3 \- $T1`"
T1=`date +%s`
${mpiclause} ${taudem2}/threshold -thresh 300  -ssa ./${testname2}ad8o.tif  -src ./${testname2}src.tif
T2=`date +%s`
echo "###2 threshold `expr $T2 \- $T1` "


echo "======================================================="
# step: aread8
${mpiclause} ${taudem1}/aread8  -p ./${testname1}p  -ad8 ./${testname1}ad8  -mf 1 1
${mpiclause} ${taudem2}/aread8  -p ./${testname2}p.tif  -ad8 ./${testname2}ad8.tif

echo "======================================================="
echo "step: Streamnet"
T1=`date +%s`
${mpiclause} ${taudem2}/streamnet  -p ./${testname2}p.tif -fel ./${testname2}fel.tif -ad8 ./${testname2}ad8.tif -src ./${testname2}src.tif  -w ./${testname2}w.tif -ord ./${testname2}ord.tif -tree ./${testname2}tree.dat -net ./${testname2}net.shp -coord ./${testname2}coord.dat
T2=`date +%s`
echo "###2 streamnet `expr $T2 \- $T1` "
# taudem MF streamnet is slow
T1=`date +%s`
${mpiclause} ${taudem1}/streamnet  -p ./${testname1}p -fel ./${testname1}fel -ad8 ./${testname1}ad8 -src ./${testname1}src  -w ./${testname1}w -ord ./${testname1}ord -tree ./${testname1}tree.dat -net ./${testname1}net.shp -coord ./${testname1}coord.dat  -mf 1 1
T2=`date +%s`
gdalbuildvrt ./${testname1}w.vrt ./${testname1}w/*.tif
gdal_translate -of GTiff ./${testname1}w.vrt ./${testname1}w.tif
gdalbuildvrt ./${testname1}ord.vrt ./${testname1}ord/*.tif
gdal_translate -of GTiff ./${testname1}ord.vrt ./${testname1}ord.tif
T3=`date +%s`
echo "###1 streamnet `expr $T2 \- $T1` `expr $T3 \- $T2` `expr $T3 \- $T1`"

echo "======================================================="
touch .end
