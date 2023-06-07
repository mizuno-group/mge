# Ubuntuでのリソース使用制限方法
Ubuntuで処理を行う・学習をするときに, コンピュータの全てのリソースを使わないようにする手法について。  
無制限に動かすと処理落ちするようなときに試して下さい。  
目次:

    1. CPUの制限(マシン全体)  
    2. CPUの制限(docker, docker compose)  
    3. メモリ使用量の制限(docker, docker compose)
    4. GPUの制限(マシン全体)  
    5. GPUの制限(docker, docker compose): 不明
    6. 230603 HIEGM8に対処した際の結果  

## 1. CPUの制限(マシン全体)
**cpufrequtils**を使うと, CPUのクロックを制限することができる。
```
$ sudo apt install cpufrequtils
```
現在のCPUの状態は, ```$ cpufreq-info```で確認できる。
```
$ cpufreq-info
analyzing CPU 0:
  driver: acpi-cpufreq
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency: 4294.55 ms.
  hardware limits: 3.00 GHz - 5.88 GHz
  available frequency steps: 4.50 GHz, 3.00 GHz
  available cpufreq governors: conservative, ondemand, userspace, powersave, performance, schedutil
  current policy: frequency should be within 3.00 GHz and 3.00 GHz.
                  The governor "powersave" may decide which speed to use
                  within this range.
  current CPU frequency is 2.99 GHz.
  cpufreq stats: 4.50 GHz:0.00%, 3.00 GHz:100.00%  (91)
analyzing CPU 1:
  driver: acpi-cpufreq
...
```
**hardware limits** が, 設定できるクロックの範囲。数字が小さいほど負荷が小さくなる。  
**current policy**が現在設定されている制限値。   
設定を変更するには, **/etc/default/cpufrequtils**ファイルを作成する。
```
$ sudo touch /etc/default/cpufrequtils
```
中には以下を書く。
```
ENABLE="true"
GOVERNOR="powersave"
MAX_SPEED=3.00GHz
MIN_SPEED=3.00GHz

```
「```ENABLE="true"```」 … 起動時にクロック制限を有効にする。  
「```GOVERNOR="powersave"```」 … クロックの変化ポリシーの設定。"powersave"は常に最低クロックで固定する。  
他には"performance"(最高で固定), "ondemand"(付加に応じて変動) など。  
「```NAX_SPEED=3.00GHz```」,「```MIN_SPEED=3.00GHz```」 … クロックの最大値と最小値。なるべく下げたい場合先程の**hardware limits**の最低値に設定する。  

その後cpufrequtilsを再起動する。
```
$ sudo service cpufrequtils restart
```
```cpufreq-info```で設定が反映されたか確認できる。
- 参考: https://freefielder.jp/blog/2020/02/ubuntu-cpufrequtils.html

## 2.CPUの制限(docker, docker compose)
dockerコマンドを用いる場合, 起動時(```docker run```または```docker start```)にオプションを指定することで, docker 1つに割り当てるリソースを制限することができる。  
オプションの指定方法はいくつかあり, 以下はその例。詳細は[dockerのリファレンス](https://matsuand.github.io/docs.docker.jp.onthefly/config/containers/resource_constraints/)を参照。  
- ```--cpus=<値>```  
コンテナが利用できるCPU数を指定  
例: ```cpus="1.5"``` … コンテナはCPUを最大1.5個分使える。
- ```--cpu-shares```  
コンテナに割り当てるCPU量の相対値。デフォルトは1024。  
例えばcpu-shares=1024のコンテナ1個とcpu-shares=512のコンテナ1個があった場合, マシンのCPUは2:1で配分される。(ただしCPU量に余裕があるときは効かない。)  

docker composeを使う場合も, 同様のオプションが用意されている。version 2(現行)では**cpus**, **cpu_shares**などの値を設定できる。以下は例。
```Dockerfile
services:
  <コンテナ名>:
    cpus: 0.5
    cpu_shares: 73
```

- 参考: https://docs.docker.com/compose/compose-file/compose-file-v2/#cpu-and-other-resources

## 3. メモリ使用量の制限(docker, docker compose)

## 4. GPUの制限(マシン全体)
**nvidia-smi**により, GPUに流れる電力の最大値を制限することにより, 使用を制限できる。
まずは```nvidia-smi -q -d POWER```により現在の電力の制限値を確認する。
```
$ nvidia-smi -q -d POWER
==============NVSMI LOG==============

Timestamp                                 : Sat Jun  3 11:59:25 2023
Driver Version                            : 525.105.17
CUDA Version                              : 12.0

Attached GPUs                             : 1
GPU 00000000:01:00.0
    Power Readings
        Power Management                  : Supported
        Power Draw                        : 20.76 W
        Power Limit                       : 350.00 W
        Default Power Limit               : 350.00 W
        Enforced Power Limit              : 350.00 W
        Min Power Limit                   : 100.00 W
        Max Power Limit                   : 350.00 W
    Power Samples
        Duration                          : 89.98 sec
        Number of Samples                 : 119
        Max                               : 33.22 W
        Min                               : 20.41 W
        Avg                               : 22.25 W
```
上の**Power Limit**が現在設定されている制限値。**Min Power Limit**から**Max Power Limit**の間の値を設定できる。  
制限を変えるには, ```sudo nvidia-smi -pl <値>```とする。
```
$ sudo nvidia-smi -pl 100
$ nvidia-smi -q -d POWER
==============NVSMI LOG==============

Timestamp                                 : Sat Jun  3 11:59:25 2023
Driver Version                            : 525.105.17
CUDA Version                              : 12.0

Attached GPUs                             : 1
GPU 00000000:01:00.0
    Power Readings
        Power Management                  : Supported
        Power Draw                        : 20.76 W
        Power Limit                       : 100.00 W
        Default Power Limit               : 350.00 W
        Enforced Power Limit              : 100.00 W
        Min Power Limit                   : 100.00 W
        Max Power Limit                   : 350.00 W
    Power Samples
        Duration                          : 89.98 sec
        Number of Samples                 : 119
        Max                               : 33.22 W
        Min                               : 20.41 W
        Avg                               : 22.25 W
```
- 参考: https://blog.amedama.jp/entry/nvidia-smi-gpu-power-limit

## 5. GPUの制限 (docker, docker compose)
GPUの個数単位で制限する方法はあるものの, 1つのGPUを分割して割り当てる方法は見つかっていません。良い方法があれば教えてください。

## 6. 230603 HIEGM8に対処した際の結果
　HIEGM8において, GPUを使う処理を行うとマシンが再起動するという症状が出ていたため, 上記のうち,  
- 1.CPU制限(マシン全体)  
- 2.CPU制限(docker)  
- 3.メモリ制限(docker)  
- 4.GPU制限(マシン全体)  
を試したところ, 1. CPU制限(マシン全体)が上手く行った。CPUのクロックを最低値に制限した所, 再起動することなくGPU処理(約40時間)を完了できた。実行速度は変わらなかった。
