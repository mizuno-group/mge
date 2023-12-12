import os
import yaml

with open("../settings/storage.yaml", "r") as f:
    data = yaml.load(f, Loader=yaml.SafeLoader)

for d in data:
    os.system(f"mount {data[d]['node-ip']}:{data[d]['local']} /mnt/cluster/{d}")
