#!/bin/bash
Time=`date "+%Y-%m-%d__%H:%M:%S"`

eval $(awk -F: -v Sum=0 '{if ($3 >= 1000 && $3 != 65534) {sum+=1; printf("All["sum"]=%s", $1)}}\
    END {printf("UserSum=%d\n", Sum)}' /etc/passwd)

MostActiveUser=`last -w | cut -d " " -f 1 | grep -v wtmp | grep -v reboot | grep -v "^$" | sort | uniq -c | sort -k 1 -n -r | awk -v num=3 '{if(num>0) {printf(" %s", $2); num--}}' | cut -c 2-`

eval $(awk -F: '{if($3==1000) printf("UserWithRoot=%s", $1)}' /etc/passwd)

Users=`cat /etc/group | grep sudo | cut -d : -f 4 | tr ',' ' '`

for i in ${Users};do
    if [[ $i == ${User_1000} ]]; then
        continue
    fi
    UserWithRoot="${UserWithRoot},$i"
done

if [[ -r /etc/sudoers ]]; then
    for i in ${All[*]};do
        grep -q -w "^${i}" /etc/sudoers
        if [[ $? -eq 0 ]]; then
            UserWithRoot="${UserWithRoot},$i"
        fi
    done
fi

UserLogedIn=`w -h | awk '{printf(",%s_%s_%s", $1, $3, $2)}' | cut -c 2-`

echo "${Time} ${UserSum} [${MostActiveUser}] [${UserWithRoot}] [${UserLogedIn}]"
