#!/bin/bash

local_item_count=( 1 8 16 32  64 128 256 512 1024 )
loop_count_1=( 1 8294400 )
loop_count_8=( 1 16 128 1036800 )
loop_count_16=( 1 8 64 640 )
loop_count_32=( 1 4 160 )
loop_count_64=( 1 2 4 16 80 )
loop_count_128=( 1 2 )
loop_count_256=( 1 2 4 8 32400 )
loop_count_512=( 1 2 16200 )
loop_count_1024=( 1 8100 )

echo "Simulation start" > test.txt

function run()
{
	echo "will run with params: " $1 " and " $2
	echo "local item count $1" " | loop count $2" >> test.txt
	result=$(./bayer_open_cl bayered_rainFruits438.png $1 $2)
	echo "			result " $result >> test.txt
}


for lic in "${local_item_count[@]}"
do
	:
	if [ $lic = 1 ]; then
		for lc in "${loop_count_1[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 8 ]; then
		for lc in "${loop_count_8[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 16 ]; then
		for lc in "${loop_count_16[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 32 ]; then
		for lc in "${loop_count_32[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 64 ]; then
		for lc in "${loop_count_64[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 128 ]; then
		for lc in "${loop_count_128[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 256 ]; then
		for lc in "${loop_count_256[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 512 ]; then
		for lc in "${loop_count_512[@]}"
		do
			:
			run $lic $lc
		done
	elif [ $lic = 1024 ]; then
		for lc in "${loop_count_1024[@]}"
		do
			:
			run $lic $lc
		done
	fi
done
