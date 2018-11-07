import os

def file_name(file_dir):   
    L=[]   
    for root, dirs, files in os.walk(file_dir):  
        for file in files:  
            if os.path.splitext(file)[1] == '.json':  
                # print(dirs,file)
                os.system('cp /home/lenovo/Document/ReignPic/{}.jpg /home/lenovo/Dataset/train/'.format(os.path.splitext(file)[0]))
                L.append(os.path.join(root, file))  
    return L  

file_dir = "/home/lenovo/Document/A1"
file_name(file_dir)
