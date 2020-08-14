# df-zerofill
Fill free space with zeros up to certain percent

# Why
It takes a lot of time to copy huge .qcow2 files over the network. And it makes
no sense to copy junk inside free space, leftovers of normal VM operation.
Often this space can't be compressed during backup operation because erased
files were encrypted or already compressed ones. Thus it's possible to save a 
lot of backup time if free space was filled with zero prior to backup operation.

# Usage

    df-zerofill.sh -d DIRECTORY [-p PERCENTS_TO_FILL] [-v]

*  -d DIRECTORY - target directory, df-zerofill will use it to create $DIRECTORY/zero-file file, example: -d /tmp
*  -p PERCENTS_TO_FILL - percents of free space to fill, number from 1 up to 95, example: -p 90
*  -v - verbosity flag, requires pv utility

Create a user (let's say zerouser) and add this script to crontab in your VM for each
filesystem (directories must reside in certain filesystems). If you have two filesystems
with /tmp in root fs and /home in separate partition, add following lines. Make sure
they complete before your backup routine:

~~~
0 0 * * * zerouser /path/to/script/df-zerofill -d /tmp
0 0 * * * zerouser /path/to/script/df-zerofill -d /home/zerouser
~~~

# Caveats
*  Do not run as root! 
*  This script is not a backup script, it is intened to be run INSIDE your VM on regular basis
*  This utility is useless if you aren't using compression during backup operation.
*  Care should be taken with percents. Do not fill all free space, otherwise you may render your system unusable.
Be sure your programs won't break during this fillup operation.
