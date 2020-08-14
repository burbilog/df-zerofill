# df-zerofill
Fill free space with zeros up to certain percent

# Why
Copying huge .qcow2 files takes a lot of time. 
It's possible to save a lot of time if these files were zero-filled
in free space. 

# Usage

    df-zerofill.sh -d DIRECTORY [-p PERCENTS_TO_FILL] [-v]

*  -d DIRECTORY - target directory, df-zerofill will use it to create $DIRECTORY/zero-file file, example: -d /tmp
*  -p PERCENTS_TO_FILL - percents of free space to fill, number from 1 up to 95, example: -p 90
*  -v - verbosity flag, requires pv utility

Create a user (let's say zerouser) and add this script to crontab in your VM for each
filesystem (directories must reside in certain filesystems). If you have two filesystems
with /tmp in root fs and /home in separate partition, add following lines before your
backup routinge:

0 0 * * * root /path/to/script/df-zerofill -d /tmp
0 0 * * * root /path/to/script/df-zerofill -d /home/zerouser

# Caveats
*  Do not run as root! 
*  This utility is useless if you aren't using compression during backup operation.
*  Care should be taken with percents. Do not fill all free space, otherwise you may render your system unusable.
Be sure your programs won't break during this fillup operation.
