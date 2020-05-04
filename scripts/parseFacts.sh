#!/bin/bash
SOURCE_DIR=${1}

# FUNCTIONS
bytestohuman() {
    # converts a byte count to a human readable format in IEC binary notation (base-1024), rounded to two decimal places for anything larger than a byte. switchable to padded format and base-1000 if desired.
    local L_BYTES="${1:-0}"
    local L_PAD="${2:-no}"
    local L_BASE="${3:-1024}"
    BYTESTOHUMAN_RESULT=$(awk -v bytes="${L_BYTES}" -v pad="${L_PAD}" -v base="${L_BASE}" 'function human(x, pad, base) {
         if(base!=1024)base=1000
         basesuf=(base==1024)?"iB":"B"

         s="BKMGTEPYZ"
         while (x>=base && length(s)>1)
               {x/=base; s=substr(s,2)}
         s=substr(s,1,1)

         xf=(pad=="yes") ? ((s=="B")?"%5d   ":"%8.2f") : ((s=="B")?"%d":"%.2f")
         s=(s!="B") ? (s basesuf) : ((pad=="no") ? s : ((basesuf=="iB")?(s "  "):(s " ")))

         return sprintf( (xf " %s\n"), x, s)
      }
      BEGIN{print human(bytes, pad, base)}')
    return $?
}

# MAIN
for server in ${SOURCE_DIR}*
do
  jq '
    .ansible_facts.ansible_hostname,
    .ansible_facts.ansible_default_ipv4.address,
    .ansible_facts.ansible_product_name,
    .ansible_facts.ansible_processor_cores,
    .ansible_facts.ansible_processor_count,
    .ansible_facts.ansible_memtotal_mb' ${server}

  arrDiskMountPoint=( $(jq -r '.ansible_facts.ansible_mounts[].mount' ${server} ) )
  arrDiskSizeAvailable=( $(jq -r '.ansible_facts.ansible_mounts[].size_available' ${server} ) )
  arrDiskSizeTotal=( $(jq -r '.ansible_facts.ansible_mounts[].size_total' ${server} ) )

  total=${#arrDiskMountPoint[@]}

  for (( i=0; i<=$(( $total -1 )); i++ ))
  do
    bytestohuman ${arrDiskSizeAvailable[${i}]}
    DiskSizeAvailable=${BYTESTOHUMAN_RESULT}
    bytestohuman ${arrDiskSizeTotal[${i}]}
    DiskSizeTotal=${BYTESTOHUMAN_RESULT}
    printf "Disk#: ${i}   Total: ${DiskSizeTotal}     Free: ${DiskSizeAvailable}     Mount: ${arrDiskMountPoint[${i}]}\n"
  done

  jq '
    .ansible_facts.ansible_distribution,
    .ansible_facts.ansible_distribution_version,
    .ansible_facts.ansible_date_time.date' ${server}
    #.ansible_facts.ansible_all_ipv4_addresses,

  printf "\n\n"
done

: <<'END'
printf "3804814196736 is equal to:"
echo 3804814196736| awk 'function human(x) {
      x[1]/=1024; 
      if (x[1]>=1000) { x[2]++; human(x); }
    }
    {a[1]=$1; a[2]=0; human(a); print a[1],substr("kMGTEPYZ",a[2]+1,1)}'



"backup"
"192.168.1.9"
"PowerEdge R410"
2
3814
13402460160
52844687360
[
  "192.168.1.9"
]
"2016-01-06"

awk 'function human(x) {
      x[1]/=1024; 
      if (x[1]>=1000) { x[2]++; human(x); }
    }
    {a[1]=$1; a[2]=0; human(a); print a[1],substr("kMGTEPYZ",a[2]+1,1)}'

END
