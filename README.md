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

# Caveats
*  Do not run as root! 
*  Do not fill all free space, otherwise you may render your system unusable
