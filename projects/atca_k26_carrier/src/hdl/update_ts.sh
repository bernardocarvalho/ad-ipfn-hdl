##!/bin/bash

if [ -z "$1" ]
then
    echo "No argument supplied"
    FILE="shapi_stdrt_dev_inc.vh"
else
    FILE="$1"
fi


OUTPUT=$(date)
OUTN=$(date +%s)
echo $FILE
echo -x "TS: "
echo "${OUTN}"
echo -x "TS: "
echo "${OUTPUT}"

# ' = \x27
#sed  "s/d163\([0-9]\+\)/(d $OUTN, 0)/"   $1 > new.vh
sed -i  "s/32\x27d\([0-9]\+\)/32\x27d$OUTN/"  $FILE
#"s/32.d\([0-9]\+\)/(32\'d$OUTN, 0)/" $1 > new2.vh
# sed  "s/32\'d\([0-9]\+\)/(32\'d $OUTN, 0)/"   $1 > new1.vh
sed -i  "s/\/\/TS .*/\/\/TS ${OUTPUT}/"   $FILE
