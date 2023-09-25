from fileList import *

for key, value in FilesDestination.items():
    with open(key,'r') as f:
        print(f"{f.name} has been prodded")


