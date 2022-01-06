#!/bin/bash
# 该脚本用于时间系数以及锁仓当量的计算，依赖 gettx.sh 脚本所获取的交易数据
#CLI=./cli-remote.sh
CLI=./cli-local.sh
# 每次记得选择 CLI 指向
testCLI=$($CLI block 1)

if [[ $testCLI = "" ]]; then
    echo "RPC脚本工具未正确配置节点"
    exit 1 # RPC 脚本工具节点配置错误，退出状态 1
fi

gtxfile=./guardtx.txt
htxfile=./honortx.txt
FILE=./txdata.txt
if [ ! -f $gtxfile ]; then
    cat txdata.txt |grep MmQitmeerMainNetGuardAddressXd7b76q|sort -k2 -u|sort -n|awk -F" " '{print $1,$2,$4,$5,$6}' >guardtx.txt
fi
if [ $htxfile ]; then
    cat txdata.txt |grep MmQitmeerMainNetHonorAddressXY9JH2y|sort -k2 -u|sort -n|awk -F" " '{print $1,$2,$4,$5,$6}' >honortx.txt
fi
# v2tx_1-to-290000.txt 为脚本 gettx.sh 输出结果

TWG=./TimeWeightGuard.txt
TWH=./TimeWeightHonor.txt

if [ ! -f $TWG ]; then
     touch $TWG
fi
if [ ! -f $TWH ]; then
    touch $TWH
fi

gRow=$(cat $TWG |wc -l)
hRow=$(cat $TWH |wc -l)

T_x_end=(90000 180000 270000 360000 450000 540000 630000 720000 810000 900000 990000 1080000)


# 获取计算起点，即旧文件的终点
lockAmountLast=`cat $TWG | sed -n '$p'|cut -d' ' -f7`
for (( m = 0,n = 20; m <=11,n <=31; ++m,++n )); do
    lockVolumeLast[$m]=`cat $TWG | sed -n '$p'|awk -F" " '{print $'$n'}'`
done

#初始化统计起点值
#lockAmount=0
#lockVolume=(0 0 0 0 0 0 0 0 0 0 0 0)
lockAmount=$lockAmountLast
for (( VAR = 0; VAR < 12; ++VAR )); do
   lockVolume[$VAR]=${lockVolumeLast[$VAR]}
done
# 数组只能通过遍历赋值


j=0
while read line
do
    ((++j))
    if [[ $j -gt $gRow ]]; then
        order=`echo ${line} | awk -F" " '{print $1}'`
        height=$($CLI block $order|jq .height)
        addr=`echo ${line} | awk -F" " '{print $3}'`
        amount=`echo ${line} | awk -F" " '{print $5}'`

        lockAmount=`echo $lockAmount $amount|awk '{printf "%0.8f\n", $1+$2}'`
        #echo "${arr[$i]}"
    # 判断资金属于哪一期的
        if [[ $height -lt ${T_x_end[0]} ]]; then
            Period=1
            Weight=`echo ${T_x_end[0]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=($Weight 5 5 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[0]} && $height -lt ${T_x_end[1]} ]]; then
            Period=2
            Weight=`echo ${T_x_end[1]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 $Weight 5 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[1]} && $height -lt ${T_x_end[2]} ]]; then
            Period=3
            Weight=`echo ${T_x_end[2]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 $Weight 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[2]} && $height -lt ${T_x_end[3]} ]]; then
            Period=4
            Weight=`echo ${T_x_end[3]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 $Weight 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[3]} && $height -lt ${T_x_end[4]} ]]; then
            Period=5
            Weight=`echo ${T_x_end[4]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 $Weight 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[4]} && $height -lt ${T_x_end[5]} ]]; then
            Period=6
            Weight=`echo ${T_x_end[5]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 $Weight 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[5]} && $height -lt ${T_x_end[6]} ]]; then
            Period=7
            Weight=`echo ${T_x_end[6]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 $Weight 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[6]} && $height -lt ${T_x_end[7]} ]]; then
            Period=8
            Weight=`echo ${T_x_end[7]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 $Weight 5 5 5 5)
        elif [[ $height -ge ${T_x_end[7]} && $height -lt ${T_x_end[8]} ]]; then
            Period=9
            Weight=`echo ${T_x_end[8]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 $Weight 5 5 5)
        elif [[ $height -ge ${T_x_end[8]} && $height -lt ${T_x_end[9]} ]]; then
            Period=10
            Weight=`echo ${T_x_end[9]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 $Weight 5 5)
        elif [[ $height -ge ${T_x_end[9]} && $height -lt ${T_x_end[10]} ]]; then
            Period=11
            Weight=`echo ${T_x_end[10]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 0 $Weight 5)
        else
            Period=12
            Weight=`echo ${T_x_end[11]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 0 0 $Weight)
        fi

        for (( m = 0; m <=11; ++m )); do
            fundsWeight[$m]=`echo $amount 100000000 ${timeWeight[$m]}|awk '{printf "%.0f\n", $1*$2*$3}'`
            lockVolume[$m]=`echo ${lockVolume[$m]} ${fundsWeight[$m]}|awk '{printf "%.0f\n", $1+$2}'`
        done
        #((++j))
        echo "$j $Period $order $height $addr $amount $lockAmount ${timeWeight[*]} ${lockVolume[*]}" >> TimeWeightGuard.txt
    fi
done < guardtx.txt



### honor pool

lockAmountLast=`cat $TWH | sed -n '$p'|cut -d' ' -f7`
for (( m = 0,n = 20; m <12,n <=31; ++m,++n )); do
    lockVolumeLast[$m]=`cat $TWH | sed -n '$p'|awk -F" " '{print $'$n'}'`
done
#初始化统计起点值
#lockAmount=0
#lockVolume=(0 0 0 0 0 0 0 0 0 0 0 0)
lockAmount=$lockAmountLast
for (( VAR = 0; VAR < 12; ++VAR )); do
   lockVolume[$VAR]=${lockVolumeLast[$VAR]}
done

j=0
while read line
do
    ((++j))
    if [[ $j -gt $hRow ]]; then
        order=`echo ${line} | awk -F" " '{print $1}'`
        height=$($CLI block $order|jq .height)
        addr=`echo ${line} | awk -F" " '{print $3}'`
        amount=`echo ${line} | awk -F" " '{print $5}'`

        lockAmount=`echo $lockAmount $amount|awk '{printf "%0.8f\n", $1+$2}'`
        #echo "${arr[$i]}"
    # 判断资金属于哪一期的
        if [[ $height -lt ${T_x_end[0]} ]]; then
            Period=1
            Weight=`echo ${T_x_end[0]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=($Weight 5 5 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[0]} && $height -lt ${T_x_end[1]} ]]; then
            Period=2
            Weight=`echo ${T_x_end[1]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 $Weight 5 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[1]} && $height -lt ${T_x_end[2]} ]]; then
            Period=3
            Weight=`echo ${T_x_end[2]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 $Weight 5 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[2]} && $height -lt ${T_x_end[3]} ]]; then
            Period=4
            Weight=`echo ${T_x_end[3]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 $Weight 5 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[3]} && $height -lt ${T_x_end[4]} ]]; then
            Period=5
            Weight=`echo ${T_x_end[4]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 $Weight 5 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[4]} && $height -lt ${T_x_end[5]} ]]; then
            Period=6
            Weight=`echo ${T_x_end[5]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 $Weight 5 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[5]} && $height -lt ${T_x_end[6]} ]]; then
            Period=7
            Weight=`echo ${T_x_end[6]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 $Weight 5 5 5 5 5)
        elif [[ $height -ge ${T_x_end[6]} && $height -lt ${T_x_end[7]} ]]; then
            Period=8
            Weight=`echo ${T_x_end[7]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 $Weight 5 5 5 5)
        elif [[ $height -ge ${T_x_end[7]} && $height -lt ${T_x_end[8]} ]]; then
            Period=9
            Weight=`echo ${T_x_end[8]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 $Weight 5 5 5)
        elif [[ $height -ge ${T_x_end[8]} && $height -lt ${T_x_end[9]} ]]; then
            Period=10
            Weight=`echo ${T_x_end[9]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 $Weight 5 5)
        elif [[ $height -ge ${T_x_end[9]} && $height -lt ${T_x_end[10]} ]]; then
            Period=11
            Weight=`echo ${T_x_end[10]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 0 $Weight 5)
        else
            Period=12
            Weight=`echo ${T_x_end[11]} $height 18000 1|awk '{printf int(($1-$2)/$3+$4)}'`
            timeWeight=(0 0 0 0 0 0 0 0 0 0 0 $Weight)
        fi

        for (( m = 0; m < 12; ++m )); do
            fundsWeight[$m]=`echo $amount 100000000 ${timeWeight[$m]}|awk '{printf "%.0f\n", $1*$2*$3}'`
            lockVolume[$m]=`echo ${lockVolume[$m]} ${fundsWeight[$m]}|awk '{printf "%.0f\n", $1+$2}'`
        done
        #((++j))
        echo "$j $Period $order $height $addr $amount $lockAmount ${timeWeight[*]} ${lockVolume[*]}" >> TimeWeightHonor.txt
    fi
done < honortx.txt

