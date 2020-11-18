#!/usr/bin/env python

import pymongo
import time
import bson
import sys


client = pymongo.MongoClient(sys.argv[1], 27017)

db = client.get_database("test_update_bomb",
                         write_concern=pymongo.WriteConcern('majority'))

collection = db.my_collection

try:
    collection.insert_one({"_id": 1, "longValue": bson.Int64(0)})
except pymongo.errors.DuplicateKeyError:
    pass

while True:
    print("> {}".format(time.time()))
    print("< {}".format(collection.update_one({"_id": 1},
                                              {"$inc": { "longValue": 1 }})))

