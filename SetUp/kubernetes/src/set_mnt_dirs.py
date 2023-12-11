import os
import yaml

with open("../settings/storage.yaml", "r") as f:
    data = yaml.load(f, Loader=yaml.SafeLoader)

node_name = os.uname().nodename
local_mount_points = []

for d in data:
    if not os.path.exists(f"/mnt/cluster/{d}"):
        os.system(f"mkdir /mnt/cluster/{d}")
    if data[d]["node-name"] == node_name:
        if not os.path.exists(data[d]["local"]):
            os.system(f"mkdir {data[d]['local']}")
        os.system(f"mount {data[d]['device']} {data[d]['local']}")
        local_mount_points.append((data[d]['local']))

S = ""
for lp in local_mount_points:
    S += f"{lp} 192.168.1.0/24(rw,async,no_root_squash) 10.244.0.0/16(rw,async,no_root_squash)\n"

open("/etc/exports", "w").write(S)

os.system("/etc/init.d/nfs-kernel-server restart")
