#!/bin/bash

##--------------------------------------------------------##
## SPS MD auto check new files on DFS and convert to ROOT ##
##--------------------------------------------------------##

data_dir_in=/home/andrii/dfs/Experiments/UA9/Students\ archive/Andrii/Timepix_SPS_protons/SPS_MD_2017_10_17/;
data_dir_out=/home/andrii/Medipix/SPS_DATA/MD_2017_10_17/TIMEPIX/;
make ascii2root_v5;

nfiles_old=$(ls -1 "$data_dir_in"*.dat | wc -l); # Initial number of files in the directory
ls "$data_dir_in"*.dat > filelist1.dat; # Initial list of the files in the directory

for fullfile in "$data_dir_in"*.dat
do
    filename=$(basename "$fullfile");
    extension="${filename##*.}";
    filename="${filename%.*}";
    ./ascii2root_v5 "$fullfile" $data_dir_out$filename.root;
done

echo "";
echo "... Waiting for the new file ...";
echo "";

while true; do
    nfiles_new=$(ls -1 "$data_dir_in"*.dat | wc -l); # get number of files in the directory
    if [ "$nfiles_new" -ne "$nfiles_old" ] # compare with previous number
    then # if they are not equal
        nfiles_old=$nfiles_new;
        for fullfile_new in "$data_dir_in"*.dat # take each file in the directory
        do
            status_it=0;
            while read fullfile_old # read each file in the file list
            do
                if [ "$fullfile_new" == "$fullfile_old" ] # compare new file with file in file list
                then
                    status_it=1;
                fi
            done < filelist1.dat
            if [ "$status_it" -ne 1 ] # if we did not find file in the file list
            then # run the script
                filename=$(basename "$fullfile_new");
                filename="${filename%.*}";
                ./ascii2root_v5 "$fullfile_new" $data_dir_out$filename.root;
            fi
        done
        ls "$data_dir_in"*.dat > filelist1.dat;
    else
        echo "";
        echo "... Waiting for the new file ...";
        echo "";
        sleep 10;
    fi
done