# Solidity 智能合约仓库
# ERC20标准合约
## 1. Basics，标准代币，无任何机制
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/Basics.sol
## 2. HoldDividendBNB，持币分红 BNB
6% 持币分红 BNB，2% 营销钱包 BNB
买卖、转账都有 8% 滑点，6% 给持币分红 BNB，2% 营销钱包 BNB
持有 200万 币才能参与分红
卖不干净，最少留 0.1 币
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/HoldDividendBNB.sol
## 3. RebaseDividendToken，Rebase 分红本币
4% 持币分红本币，1% 营销钱包本币
买卖5%滑点，4%给持币分红，1%营销钱包
未开启交易时，只能项目方加池子，加池子未开放交易，机器人购买高滑点
手续费白名单，分红排除名单
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/RebaseDividend.sol
## 4. LPDividendUsdt，加LP分红
加 LP 分红 USDT，推荐关系绑定，推荐分红本币，营销钱包，限购，自动杀区块机器人
买卖14%滑点，3%给加LP池子分红，4%分配10级推荐，1%营销钱包，1%备用拉盘，5%进入NFT盲盒
推荐分红，1级0.48%,2级0.44%,3级0.42%，4-10级各0.38%
限购总量 1%
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/LPDividend.sol
## 5. AddUsdtLP，回流USDT池子
USDT 回流加池子，营销钱包，销毁
买卖10%滑点，3%销毁，3%回流筑池（1.5%币、1.5%U），3%LP分红 DAPP实现，1%基金会（U到账）
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/AddUsdtLP.sol
## 6. RateFreely，自由设置买卖不同的手续费
买15%滑点，卖出5%滑点，分别流向不同的地址
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC20/RateFreely.sol

# ERC721标准合约
## 1. Basics，标准代币，无任何机制
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC721/Basics.sol

# ERC1155标准合约
## 1. Basics，标准代币，无任何机制
https://github.com/sdzczh/solidity-contract/blob/main/contract/ERC1155/Basics.sol

# 质押合约
## 1. 质押代币奖励代币，推荐人分销奖励
1. 向合约内质押token，奖励额度为质押数量的3倍，每天可提千分之三
质押的币直接销毁
2. 绑定推荐关系接口
3. 获得推荐人产出数量的一定百分比提现额度 直推25%
间接50%。扣除当前用户挖矿总额
https://github.com/sdzczh/solidity-contract/blob/main/contract/Pledge/1.sol
### 区块链 Solidity 智能合约交流QQ群：646415507