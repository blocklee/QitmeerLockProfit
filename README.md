# QitmeerLockProfit
Qitmeer Locking Profit Calculation

Qitmeer 锁仓收益计算脚本

使用说明：

- 先使用 gettx.sh 脚本获取交易信息，建立起交易数据文件（txdata.txt）

- 再利用 weight-add.sh 脚本计算时间权重以及锁仓当量，生成 TimeWeightGuard.txt 和 TimeWeightHonor.txt

- 最后利用 profit.sh 脚本计算收益

TimeWeightGuard.txt 和 TimeWeightHonor.txt 两个文件中已经包含了每笔资金在 12 期的时间权重，以及当前数据尾对应的每一期的锁仓当量（lockVolume），由于新数据的进来会造成 lockVolume 的增加，但不会 TimeWeight 的结果，因此 TimeWeight 文件可以追加，而最后的收益文件 ProfitGuard.txt 和 ProfitHonor.txt 中当前期以及未来期的收益值会发生变化，因此收益文件每次要重新生成（或者得更新对应期数的收益列）

