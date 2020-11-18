# Steps to reproduce #

The following assumes:

* you're running on a Linux machine
* docker is installed and functioning correctly
* python3 is installed

1. Create a python3 virtualenv

    virtualenv -p python3 .venv

1. Activate it and install the pymongo pip package

    source .venv/bin/activate
    pip install -r reqs.txt

1. Boot a three node mongo:3.6 cluster by calling `./run.sh`

1. Confirm that the cluster formed ok by running the mongo cli on the primary, and after waiting for it to be elected to PRIMARY checking the replica set status:

    $ docker exec -it mongo-27017 mongo
    rs0:PRIMARY> rs.status()["ok"]
    1

   You can also confirm that there is a proper three node mongo cluster:

    rs0:PRIMARY> conf = rs.status(); for (member in conf["members"]) { print(conf["members"][member]["stateStr"]); }
    PRIMARY
    SECONDARY
    SECONDARY

1. Run `./client.py $(./docker_ips mongo-27017)`. You should see it constantly output something like:

    > 1603817559.9675696
    < <pymongo.results.UpdateResult object at 0x7ff700cce690>

   Meaning an Update was issued, and an UpdateResult came back.

1. In another window, run `./repro.sh` to rotate one secondary out.

   That should be enough to trigger this bug. You should see a timestamp but no corresponding UpdateResult:

    > 1603817710.6663787

   If not, repeat the steps - the failure is non-deterministic.

