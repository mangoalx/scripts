#!/system/bin/sh

server=http://10.1.0.213/artifacts/testfiles/
md5sums="md5sums"

curl -O $server$md5sums

mkdir download
cd download

i=0
while true; do
    filename=$(( ($i % 2000) + 1 ))

    #delete files every 5GB
    if (( $i % 500 == 0)); then
        rm *
    fi

    curl -O $server$filename

    if [ ! -f "$filename" ]; then
        echo 'cannot download file'
        exit 1
    fi

    #flush cache files - force to re-read from disk
    echo 3 | tee /proc/sys/vm/drop_caches

    grep "`md5sum $filename`" ../md5sums
    if [ "$?" -eq 1 ]; then
        echo "Corrupted files $filename"
        exit 2
    fi

    i=$(($i+1))
    echo $i \* 10MB
    date
done
