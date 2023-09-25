import os
from fileList import *

for inp, output in FilesDestination.items():
    source = inp
    destination = os.path.join(output,inp)
    print("")
    print (f"source file {source} found: {os.path.isfile(source)} ------> desitnation file {destination} found: {os.path.isfile(destination)}")

    #check for destination path and create if not
    if not os.path.exists(output):
        print("no valid destination path")
        print(f"created at {output}")
        os.makedirs(output)
    # check for preexisting file and delete it if there to be replaced with link
    if os.path.isfile(destination):
        print(f"{destination} already exits")
        if os.path.samefile(source, destination):
            print("already linked!")
            continue
        else:
            print(f"different file: deleting {destination}")
            os.remove(destination)

    #create links
    os.link(source, destination)
    print (f"{source} linked to {destination}")
