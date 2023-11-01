import fileList

for key, value in fileList.HardLinkFilesDestination.items():
    with open(key,'r') as f:
        print(f"{f.name} has been prodded")

for key, value in fileList.SoftLinkFilesDestination.items():
    with open(key,'r') as f:
        print(f"{f.name} has been prodded")

