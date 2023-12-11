# Kubernetesまとめ

## Kubernetesとは

コンテナオーケストレーション用ソフトウェア。複数のコンピュータをクラスタ化し、コンテナ（docker containerなど）のデプロイを管理できる。計算資源の割り当てや、不具合の発生時のセルフヒーリングなどを自動実行してくれる。k8sと略することがある。

## Kubernetesで可能なこと

効率的な計算資源配分及び分散コンピューティング。PCという単位からクラスタという単位で計算資源を使用することが可能になる。

## Kubernetesを使う上での注意点

Kubernetesの特徴はまだ「枯れていない」技術であるという点である。既に安定したソフトウェアとは違い、リリースの度に改善が行われ、しばしば重大な変更が加えられる。そのため、定期的なメンテナンス及び最新版へのフォローがないと、問題が起こる可能性が高い。また、各技術間での依存関係が複雑であるため、問題解決に根気が必要っである。

## 構築方法

オンプレミス環境（クラウドではないローカル環境）でKubernetesの構築のために必要なステップは以下の通りである：

1. Dockerのインストール
2. kubelet, kubectl, kubeadmのインストール
3. ネットワーク環境の整備
4. kubeadmによるクラスター構築
5. CNIによる仮想ネットワークの構築
6. GPUプラグインの導入 (option)
7. kubeflowの導入（option）

## Dockerのインストール

container runtimeとしてdockerを導入する。このインストール方法自体は通常のインストール方法と同じでよい。

しかし、```/etc/docker/daemon.json```は以下のように設定する。

```
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

```cgroupdriver```とは？

## kubelet, kubectl, kubeadmのインストール

Kubernetesを動かす基本的なソフトウェアであるkubelet, kubectl, kubeadmをインストールする。

### kubelet

コントロールプレーン（クラスタの管理ノード）と通信して、Kubernetes上の各種処理を実行する。

### kubectl

Kubernetesクラスタを制御するためのコマンドラインツールを提供する。

### kubeadm

Kubernetesの主に構築面に関する操作を行うコマンドラインツールを提供する。

### インストール手順

必要なソフトのインストール

```
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https curl
```
GoogleのGPG key追加 
```
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo $ apt-key add -
```
GoogleのKubernetesのリポジトリを設定
```
$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```
各ソフトウェアをインストール
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

## ネットワーク環境の整備

Kubernetesで計算機クラスタを構築する前に、ネットワーク環境を整備しておく必要がある。

### イントラネットの構築

研究室のイントラネットの構成は基本的に以下のようになっている。

インターネット---研究室ルータ---コントロールプレーン---構成ノード

コントロールプレーンと構成ノードを隔離したイントラネットを構築する。

#### DHCPサーバの構成

イントラネット上ではグローバルIPアドレス（```133.11.48.1```など）とは異なるIPアドレスを設定する。今回は```192.168.1.x```というアドレスを用いる。（よく使われるプライベートアドレス）。この割り当てを行うサーバをDHCPサーバという。QNAPはこのDHCPサーバからIPアドレスを取得する。

コントロールプレーンノードにDHCPサーバを構築する。Ubuntuではisc-dhcp-serverというソフトウェアがDHCPサーバとして頻用されている。

```
$ sudo apt install isc-dhcp-server
```

```/etc/default/isc-dhcp-server```ファイルを以下のように編集。

```
INTERFACESv4="enp1s0"
INTERFACESv6="enp1s0"
```

ここで、```enp1s0```はコントロールプレーンのイントラネット向けのネットワークインターフェースである。異なる名前の場合は適宜変更する。

DHCPサーバの設定は```/etc/dhcp/dhcpd.conf```上に存在する。

ホストネームとMACアドレスのペアを設定。netmaskによってとりうるIPアドレスの範囲を指定できる。
```
authoritative;

subnet 192.168.1.0 netmask 255.255.255.0 {
 option routers 192.168.1.1;
 option broadcast-address 192.168.1.255;


host filsev-desktop {
  hardware ethernet 24:4b:fe:b1:4c:43;
  fixed-address 192.168.1.10;
}

host QSW-M1208-8C {
  hardware ethernet 24:5e:be:56:fa:31;
  fixed-address 192.168.1.11;
}

host node1 {
  hardware ethernet a8:a1:59:30:5d:51;
  fixed-address 192.168.1.12;
}

}
```

以下、全てのノードで行う

### iptablesがブリッジを通過するトラフィックを処理できるようにする

```
$ cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

### iptablesをレガシーに変更

```
$ sudo apt-get install -y iptables arptables ebtables
$ sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
$ sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
$ sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
$ sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy
```

### 必須ポートを開ける

ufwで以下のポートを開ける。limitではなくallowを使用。ただし送信元は```192.168.1.0/24```及び```10.244.0.0/16```（後述）。

コントロールプレーン

- 6443
- 2379
- 2380
- 10250
- 10251
- 10252

ワーカーノード
- 10250
- 30000-32767

### IPマスカレードの設定

イントラネットの内側から外側のインターネットを使うための設定。コントロールプレーンで以下のコマンドを実行。

```
$ sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eno1 -j MASQUERADE
```

ただし、eno1はコントロールプレーンの外側のインターネットへのネットワークインターフェース。192.168.1.0/24はイントラネットのIPアドレス。

### /etc/default/kubeletへの変数の登録

```/etc/default/kubelet```に以下を書き込む

```
KUBELET_EXTRA_ARGS=--node-ip=192.168.1.xx
```

ただし、xxの部分にはそのノードのIPアドレスを入れる。

## kubeadmによるクラスタの構築

swap領域を使わないようにする。swap領域とはRAMに保存できなくなった情報を一時的に保存するハードドライブの一部の領域である。Kubernetesにおいてswap領域を無効化する必要があるのは、swap領域を使う設定であるとハードウェア資源の扱いが難しくなるという技術的な問題が原因らしい。

一時的にswapをoffする。(再起動で復活)
```
$ sudo swapoff -a
```

永続的にswapをoffするには```/etc/fstab```のswapの行をコメントアウト。

もともとswapという機能自体はマシンの性能をうまく引き出すためのものなので、swapoffに伴ってパフォーマンスが低下する可能性に留意。

```
$ sudo kubeadm init --apiserver-advertise-address=192.168.1.10 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=1
```

```--apiserver-advertise-address=192.168.1.10```はコントロールプレーンのIPアドレスを入力する。これを抜かすと、イントラネット向けのIPではなく、インターネット向けにIPが使われてしまうので注意。

```--pod-network-cidr=10.244.0.0/16```はKubernetesが作る仮想ネットワークで使用可能なIPアドレスを明記する。これは仮想ネットワーク構築用のプラグインであるflannelのデフォルト設定と合わせている。他のいろいろな設定と依存関係にあり、また、要求するIPアドレスの量も多く(2^16)他とかぶると問題が起きるので、デフォルト設定のまま使うのが無難。

これで、以下のような出力が出れば成功。

```
[init] Using Kubernetes version: v1.21.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [filsev-desktop kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.10]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [filsev-desktop localhost] and IPs [192.168.1.10 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [filsev-desktop localhost] and IPs [192.168.1.10 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 13.004314 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.21" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node filsev-desktop as control-plane by adding the labels: [node-role.kubernetes.io/master(deprecated) node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node filsev-desktop as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: ubptkc.w4jzuknripa0p3z7
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.10:6443 --token ubptkc.w4jzuknripa0p3z7 \
        --discovery-token-ca-cert-hash sha256:b9aad86ca0adce7b5acc4b8dd4a48dc97bf0fcfcd34a582f00cb96057d1c8cc1
```

このあと、以下のコマンドを実行。

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```kubectl get nodes```コマンドで以下のような表示が出てくる。（初回は必ずしもSTATUSがReadyとは限らない）

```
$ kubectl get nodes
NAME             STATUS   ROLES                  AGE   VERSION
filsev-desktop   Ready    control-plane,master   30m   v1.21.1
```

## CNIによる仮想ネットワークの構築

ここではflannelを用いる。calicoやweaveなども試したが、最終的にはflannelがうまくいった。

https://github.com/flannel-io/flannel/blob/master/Documentation/kube-flannel.yml

などからkube-flannel.ymlをダウンロード。今回は特にカスタマイズするところはないのでそのまま以下のコマンドにより導入する。

```
$ kubectl apply -f kube-flannel.yml
```

注：このあたりが一番ハマりやすい。

```
$ kubectl get pods -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-558bd4d5db-b22pq                 1/1     Running   0          37m
coredns-558bd4d5db-l7rmf                 1/1     Running   0          37m
etcd-filsev-desktop                      1/1     Running   0          37m
kube-apiserver-filsev-desktop            1/1     Running   0          37m
kube-controller-manager-filsev-desktop   1/1     Running   0          37m
kube-flannel-ds-nj9wf                    1/1     Running   0          13s
kube-proxy-vb4ld                         1/1     Running   0          37m
kube-scheduler-filsev-desktop            1/1     Running   0          37m
```
coredns、proxy、flannelなどのpodが立ち上がっていることを確認。

さらに、ワーカーノードをkubernetesに参加させる。

以下のコマンドを実行。このtoken情報はkubeadm initで出てきたものを用いる。

```
$ sudo kubeadm join 192.168.1.10:6443 --token ubptkc.w4jzuknripa0p3z7 \
        --discovery-token-ca-cert-hash sha256:b9aad86ca0adce7b5acc4b8dd4a48dc97bf0fcfcd34a582f00cb96057d1c8cc1
```

TLS Bootstrapのところで止まっていると、iptablesやufwの問題の可能性が大。

また、flannelを使えるように以下のコマンドでroutingの設定を行う。

```
$ sudo route add default gw [そのワーカーノードのアドレス]
```

しばらく待つとflannelが使えるようになる。

コントロールプレーンで```kubectl get nodes```によりノードの参加を確認。

```
$ kubectl get nodes
NAME             STATUS   ROLES                  AGE     VERSION
filsev-desktop   Ready    control-plane,master   48m     v1.21.1
node1            Ready    <none>                 6m23s   v1.21.1
```

★問題が起きたときのtips

- iptablesのkubernetes-servicesのrejectを消す。
- ```/var/log/pods```でlogが見られる。
- ufw limitになっているせいでエラーが出てないか確認。
- ```/etc/cni/net.d```ディレクトリにflannel関連以外のファイルがあれば削除。

これで、kubernetesの最低限の形はできた。テストとしてnginxをdeployしてみる。nginxはwebサーバシステムの一種である。エンジンエックスと読むらしい。

非常に簡単で、以下のyamlファイルを```nginx-deployment.yaml```という名前で作成する。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

docker imageである```nginx:1.7.9```を元にpodを作成し、ワーカーノードにdeployする。

```
$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
```

以下のコマンドでpodを見てみるとnginxのpodがワーカーノードに作成されている。

```
$ kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-5d59d67564-rq8cj   1/1     Running   0          44s   10.244.1.2   node1   <none>           <none>
```

ワーカーノードからIPアドレス```10.244.1.2```にhttpでアクセス可能である。

```
$ wget http://10.244.1.2
--2021-07-19 19:11:03--  http://10.244.1.2/
10.244.1.2:80 k¥šWfD~Y... ¥šW~W_
HTTP kˆ‹¥šB’áW~W_ÜT’…cfD~Y... 200 OK
wU: 612 [text/html]
`index.html' kÝX-

index.html                            100%[=======================================================================>]     612  --.-KB/s    in 0s

2021-07-19 19:11:03 (176 MB/s) - `index.html' xÝXŒ† [612/612]

$ cat index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## GPUプラグインの導入 (option)

https://kubernetes.io/ja/docs/tasks/manage-gpus/scheduling-gpus/

KubernetesでGPUを使うためにいくつか下準備が必要になる。

- Kubernetesのノードに、NVIDIAのドライバーがあらかじめインストール済みでなければならない。
- Kubernetesのノードに、nvidia-docker 2.0があらかじめインストール済みでなければならない。
- KubeletはコンテナランタイムにDockerを使用しなければならない。
- runcの代わりにDockerのデフォルトランタイムとして、nvidia-container-runtimeを設定しなければならない。
- NVIDIAのドライバーのバージョンが次の条件を満たさなければならない ~= 384.81。

上記要件を満たしていれば、下記よりGPUスケジューリングをするためのpluginを導入できる。
```
$ kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml
```

GPUのplugin podが立ち上がる。

```
$ kubectl get pods -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-558bd4d5db-b22pq                 1/1     Running   0          72m
coredns-558bd4d5db-l7rmf                 1/1     Running   0          72m
etcd-filsev-desktop                      1/1     Running   0          72m
kube-apiserver-filsev-desktop            1/1     Running   0          72m
kube-controller-manager-filsev-desktop   1/1     Running   0          72m
kube-flannel-ds-bv6jm                    1/1     Running   0          30m
kube-flannel-ds-nj9wf                    1/1     Running   0          35m
kube-proxy-4l55g                         1/1     Running   0          30m
kube-proxy-vb4ld                         1/1     Running   0          72m
kube-scheduler-filsev-desktop            1/1     Running   0          72m
nvidia-device-plugin-daemonset-t5vln     1/1     Running   0          10s
```

うまくいかないときは、前述の要件が満たされていない可能性が高い。

テストとして、以下のtensorflowのpodを導入する。```tens-pod.yml```

```
apiVersion: v1
kind: Pod
metadata:
  name: tens-pod
spec:
  containers:
    - name: tens-container
      image: tensorflow/tensorflow:latest-gpu-py3
      command: ["/bin/sleep"]
      args: ["3600"]
      resources:
        limits:
          nvidia.com/gpu: 1
```

```
$ kubectl apply -f tens-pod.yml
```

すると以下のようなtensorflowが使えるpodが作成される。

```
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5d59d67564-rq8cj   1/1     Running   0          24m
tens-pod                            1/1     Running   0          53s
```

以下のコマンドでpodを直接操作できる。

```
$ kubectl exec -it tens-pod -- /bin/bash

________                               _______________
___  __/__________________________________  ____/__  /________      __
__  /  _  _ \_  __ \_  ___/  __ \_  ___/_  /_   __  /_  __ \_ | /| / /
_  /   /  __/  / / /(__  )/ /_/ /  /   _  __/   _  / / /_/ /_ |/ |/ /
/_/    \___//_/ /_//____/ \____//_/    /_/      /_/  \____/____/|__/


WARNING: You are running this container as root, which can cause new files in
mounted volumes to be created as the root user on your host machine.

To avoid this, run the container by specifying your user's userid:

$ docker run -u $(id -u):$(id -g) args...

root@tens-pod:/#
```

pythonでtensorflowが使えること、nvidia-smiでGPU情報を読み出せることを確認。

```
root@tens-pod:/# python
Python 3.6.9 (default, Nov  7 2019, 10:44:02)
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
2021-07-19 10:29:11.813663: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libnvinfer.so.6
2021-07-19 10:29:11.814404: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libnvinfer_plugin.so.6
>>> exit()
root@tens-pod:/# nvidia-smi
Mon Jul 19 10:29:27 2021
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 465.31       Driver Version: 465.31       CUDA Version: 11.3     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:0C:00.0 Off |                  N/A |
| 50%   31C    P8     7W /  75W |    438MiB /  3903MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
root@tens-pod:/#
```

ちなみに、CNIをたどって別のpodにアクセスできる。（さきほどのnginxサーバにアクセス）

```
root@tens-pod:/# curl http://10.244.1.2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```