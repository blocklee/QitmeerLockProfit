#!/bin/bash
# awk '{if ($2 == "'$p'") print $0}'
# 选出第2列的值和变量p的值相等的所有行，并全部打印出来 $0 表示全部列，若改为 $1,则打印第一列
# 表头
# number, period, blockorder, height, address, amount, profit1, profit2, profit3, profit4, profit5, profit6, profit7,profit8, profit9, profit10, profit11, profit12, pool

g=./TimeWeightGuard.txt
h=./TimeWeightHonor.txt

threshold1=0.25
threshold2=0.40
threshold3=0.50
for (( m = 1,n = 20; m <= 12,n<=31; ++m,++n )); do
    gLockVolume[$m]=`cat $g|sed -n '$p'|cut -d' ' -f$n`
    hLockVolume[$m]=`cat $h|sed -n '$p'|cut -d' ' -f$n`
done
# 最后一行 '&p'，获取锁仓当量，因新资金不会在上一期产生资金权重，因此不会对上一期的锁仓当量造成影响

echo "${gLockVolume[*]}"
echo "${hLockVolume[*]}"

for (( p = 1; p <= 12; ++p )); do
    gTotalLockAmount[$p]=`cat $g|awk '{if ($2 == "'$p'") print $0}'|sed -n '$p'|cut -d' ' -f7`
    hTotalLockAmount[$p]=`cat $h|awk '{if ($2 == "'$p'") print $0}'|sed -n '$p'|cut -d' ' -f7`
    # 选取出第2列期数值和变量p相等时，打印出最后一行，获取总锁仓量
    TotalLockAmount[$p]=`echo ${gTotalLockAmount[$p]} ${hTotalLockAmount[$p]}|awk '{printf "%0.8f\n", $1+$2}'`
    StakingRate[$p]=`echo ${TotalLockAmount[$p]} $p 1800000|awk '{printf "%0.4f\n", $1/($2*$3)}'`
    ratio[$p]=`echo ${StakingRate[$p]} $threshold1 $threshold2 $threshold3 0.38 0.5 0.8 1|awk '{if($1<$2) printf "%0.2f\n", $5; else if($1>=$2&&$1<$3) printf "%0.1f\n", $6; else if($1>=$3&&$1<$4) print "%0.1f\n", $7; else print $8}'`
    actualReward[$p]=`echo 48600 $p 1 ${ratio[$p]} 100000000|awk '{printf "%0.0f\n", $1*($2+$3)*$4*$5}'`
    # 单仓奖励
done

echo "${gTotalLockAmount[*]}"
echo "${hTotalLockAmount[*]}"
echo "${TotalLockAmount[*]}"
echo "${TotalLockAmount[1]}"
echo "${StakingRate[*]}"
echo "${ratio[*]}"
echo "${actualReward[*]}"

# awk '{if ($2 == "2") print $0}'
# 筛选出第二列数据 等于 “2”的行，并全部打印出来


#StakingRate=`echo $TotalLockAmount $TotalOutput|awk '{printf "%0.4f\n", $1/$2}'`
#获取最后一行的数据

while read line
do
    data=`echo ${line}|awk -F" " '{print $1,$2,$3,$4,$5,$6}'`
    amount=`echo ${line}| awk -F" " '{print $6}'`
    pool=guard
    for ((i=1,j=8; i<=12,j<=19; ++i,++j )); do
        gTimeWeight[$i]=`echo ${line}|cut -d' ' -f$j`
        Qitprofit[$i]=`echo ${actualReward[$i]} $amount ${gTimeWeight[$i]} 100000000 ${gLockVolume[$i]}|awk '{printf int($1*$2*$3*$4/$5)}'`
        profit[$i]=`echo ${Qitprofit[$i]} 100000000|awk '{printf "%0.8f\n", $1/$2}'`
    done
    echo "$data ${profit[*]} $pool" >> ProfitGuard.txt
done < TimeWeightGuard.txt


while read line
do
    data=`echo ${line}|awk -F" " '{print $1,$2,$3,$4,$5,$6}'`
    amount=`echo ${line}|awk -F" " '{print $6}'`
    pool=honor
    for ((i=1,j=8; i<=12,j<=19; ++i,++j )); do
        hTimeWeight[$i]=`echo ${line}|cut -d' ' -f$j`
        Qitprofit[$i]=`echo ${actualReward[$i]} $amount ${hTimeWeight[$i]} 100000000 ${hLockVolume[$i]}|awk '{printf int($1*$2*$3*$4/$5)}'`
        profit[$i]=`echo ${Qitprofit[$i]} 100000000|awk '{printf "%0.8f\n", $1/$2}'`
    done
    echo "$data ${profit[*]} $pool" >> ProfitHonor.txt
done < TimeWeightHonor.txt

# sort -n -k1  按列从小到大排列数据；sort -rn -k1 加r从大到小
#
#语句：cat testfile | sort |uniq
#结果：排序文件，默认是去重； uniq -c 排序之后删除了重复行，同时在行首位置输出该行重复的次数