#!/bin/bash
# 获取非 coinbase 交易，并且去除找零交易；并且去掉自己给自己转的utxo规整交易

#交易筛选，1）看确认数，普通交易 confirmations 至少为10，coinbase 交易 720 成熟（只是状态还不稳定，最近720（10）块才会存在的情况）；
# 2）合法交易 txvalid = true；3）重复交易 duplicate = true，不重复为空；4）vin地址 = vout地址，找零交易去除；自己给自己转的交易也去除；
# 5）coinbase 交易最终给不给,要判断块的红蓝色，请求 isblue <hash> RPC。普通交易不用管红蓝色

#CLI=./cli-remote.sh
CLI=./cli-local.sh
# 根据实际情况配置好 cli 脚本调取节点信息的 RPC 配置，local 表示使用本地节点（user=qitmeer,pass=qitmeer123,port=18131 与节点配置文件设置相同）

#echo "order TxID txvalid vinaddr voutaddr amount"

start=1
end=290000
# start和end是每次获取数据的起始区块和结束区块order；注意二次获取数据时的起点设置，不要给 txdata.txt 数据造成重复

for (( i = $start; i <= $end; ++i )); do
    blockData=$($CLI block $i|jq .)
    confirmations=`echo $blockData|jq .confirmations`
    hash=`echo $blockData|jq .hash -r`
    isblue=$($CLI isblue $hash)
    if [[ $isblue -ne 1 ]]; then
        echo "$i $hash $isblue notblue" >> txlog.txt
        # 把红色块记录下来
    fi

    for (( j = 1; j <= 20; ++j )); do
        data=$(echo $blockData| jq .transactions[$j])
        #echo "$i $data"
        if [[ $data = null ]]; then
            #echo "block=$i j=$j data=$data"
            break
            # 交易数据为空，代表该区块交易已遍历完毕，break 中断跳出交易遍历循环
        fi
        TxID=`echo $data|jq .txid -r`
        txsvalid=`echo $data|jq .txsvalid -r`
        # 每一个交易都有一个 txvalid 标记，为 true 证明交易有效；否则无效


        if [[ $txsvalid != true ]]; then
            echo "$i $TxID $txsvalid invalid" >> txlog.txt
            continue
            # 交易合法性判定，不为 true 交易无效，进入下一条循环,记录非法交易
        fi

        duplicate=`echo $data|jq .duplicate -r`
        # 非重复交易 duplicate 为空 “=null”；重复交易 duplicate=true
        if [[ $duplicate = true ]]; then
            echo "$i $TxID $txsvalid duplicate" >> txlog.txt
            continue
        fi

        # transactions[0] 是coinbase交易，去掉
        # 只选取 2类交易，且去掉找零vout
        # 所有的 vin 必定是某一个uxto的vout，最源头是coinbse交易的vout；vin不可能是两个不同的地址，只会的同一个地址向单个或多个地址转账
        vinData=`echo $data|jq .vin[0]`
        vindata=`echo $vinData|jq '.|"\(.txid) \(.vout)"' -r 2>&1`
            #echo "$vindata"
        txid=`echo $vindata|cut -d' ' -f1`
        n=`echo $vindata|cut -d' ' -f2`
        N=`expr $n + 0`
        # n 是字符，不能直接用在后边的 vout[$n], 利用expr把n转化成整型 N
        vinaddress=$($CLI tx $txid|jq .vout[$N]|jq .scriptPubKey.addresses[] -r 2>&1)

        # vout则不同，可能有多个不同的vout对象
        for (( h = 0; h < 20; ++h )); do
            voutData=`echo $data|jq .vout[$h]`
            if [[ $voutData = null ]]; then
                break
            fi
            voutdata[$h]=`echo $voutData|jq '.|"\(.amount) \(.scriptPubKey.addresses[])"' -r 2>&1`
            voutaddr[$h]=`echo ${voutdata[$h]}|cut -d' ' -f2`
            qitvoutamount[$h]=`echo ${voutdata[$h]}|cut -d' ' -f1`
            voutamount[$h]=`echo ${qitvoutamount[$h]} 100000000|awk '{printf "%0.8f\n", $1/$2}'`
            if [[ ${voutaddr[$h]} = $vinaddress ]]; then
                #echo "$i $TxID $vinaddress ${voutaddr[$h]}" >> selfTx.txt
                continue
            else
                echo "$i $TxID $txsvalid $vinaddress ${voutaddr[$h]} ${voutamount[$h]}" >>txdata.txt
                #>> v2tx_$start-to-$end.txt
            fi
        done
    done
done

# 得到的结果由于可能存在不同块里包含了同一个交易的情况，需要再对结果进行去重复（uniq 删除连续的重复行，非整个文件的重复行，故先用sort排序，将重复行放一起）
# sort -t ','  -k 2,5 -u  指定按第2至5列去重复
# 其中 -t 指定列之间的分隔符，空格为分隔符，可以不要 -t ， -k 指定从第几列到第几列作为去重标准
# 最后结果执行   sort -k 2,5 -u  去重复

# sort -n 第一列按纯数字排序
# sort 默认按首字母、首数字排序
