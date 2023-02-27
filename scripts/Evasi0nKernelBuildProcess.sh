KERNEL_SOURCE=$1
KERNEL_SOURCE_BRANCH=$2
KERNEL_DEFCONFIG=$3
KERNEL_NAME=$4

echo kernel source : $KERNEL_SOURCE
echo kernel source bach : $KERNEL_SOURCE_BRANCH
echo kernel defconfig : $KERNEL_DEFCONFIG
echo kernel name : $KERNEL_NAME

echo download kernel source
cd $GITHUB_WORKSPACE && mkdir kernel_workspace && cd kernel_workspace
git clone $KERNEL_SOURCE -b $KERNEL_SOURCE_BRANCH android-kernel --depth=1

echo delete yaml scrpit
rm $GITHUB_WORKSPACE/kernel_workspace/android-kernel/scripts/dtc/yamltree.c
cp $GITHUB_WORKSPACE/patch/EcrosoftXiao_kernel/scripts/dtc/* $GITHUB_WORKSPACE/kernel_workspace/android-kernel/scripts/dtc


echo add kernelsu
cd $GITHUB_WORKSPACE/kernel_workspace/android-kernel
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$KERNEL_DEFCONFIG
echo "CONFIG_HAVE_KPROBES=y" >> arch/arm64/configs/$KERNEL_DEFCONFIG
echo "CONFIG_KPROBE_EVENTS=y" >> arch/arm64/configs/$KERNEL_DEFCONFIG

curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -

echo add docker config
cd $GITHUB_WORKSPACE/kernel_workspace/android-kernel
cat << EOF >> arch/arm64/configs/$KERNEL_DEFCONFIG
CONFIG_NAMESPACES=y
CONFIG_NET_NS=y
CONFIG_PID_NS=y
CONFIG_IPC_NS=y
CONFIG_UTS_NS=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_SCHED=y
CONFIG_CPUSETS=y
CONFIG_MEMCG=y
CONFIG_KEYS=y
CONFIG_VETH=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_NETFILTER=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
CONFIG_NETFILTER_XT_MARK=y
CONFIG_IP_NF_NAT=y
CONFIG_NF_NAT=y
CONFIG_POSIX_MQUEUE=y
CONFIG_NF_NAT_IPV4=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_CGROUP_BPF=y
CONFIG_USER_NS=y
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
CONFIG_CGROUP_PIDS=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_BLK_CGROUP=y
CONFIG_BLK_DEV_THROTTLING=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_NET_CLS_CGROUP=y
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_IP_VS=y
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_RR=y
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_APPARMOR=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_VXLAN=y CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_CRYPTO=y CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_GHASH=y CONFIG_XFRM=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_ALGO=y
CONFIG_INET_ESP=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_IPVLAN=y
CONFIG_MACVLAN=y
CONFIG_DUMMY=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_AUFS_FS=y
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BLK_DEV_DM=y
CONFIG_DM_THIN_PROVISIONING=y
CONFIG_OVERLAY_FS=y
EOF

echo change build config
cd $GITHUB_WORKSPACE/kernel_workspace/android-kernel
rm .git -R
sed -i '/supported.versions.*/d' anykernel.sh
sed -i '/do.devicecheck.*/d' anykernel.sh

sed -i "s/KERNEL_NAME=.*/KERNEL_NAME=${KERNEL_NAME}-"$(date "+%Y%m%d%H%M%S")"/g" build.sh


# echo build kernel
# cd $GITHUB_WORKSPACE/kernel_workspace/android-kernel
# sudo bash build.sh
# pwd
