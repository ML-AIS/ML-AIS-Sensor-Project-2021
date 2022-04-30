
# Program to create images from file
# ------------------------------------------
# 0.    Read Data File
# 1.    Create Images
# ------------------------------------------
import pandas as pd
import numpy as np
import cv2
from PIL import Image
import os
import matplotlib.pyplot as plt


print("begin program ...")

# 0.    Read Data File
# data_path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-data/2022.03.11_all_data.xls"
data_path = "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.02.11_all_data.xls"
# label_path = "C:/workspace/FRA-UAS/semester3/ML-AIS/ML-data/2022.04.14/all_label.xls"
folder_name = ["data/2022.02.11",
               "data/2022.02.18",
               "data/2022.02.18.2",
               "data/2022.03.04",
               "data/2022.03.04.2",
               "data/2022.03.11",
               "data/2022.04.14"]


data_path_arr = ["C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.02.11_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.02.18_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.02.18.2_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.03.04_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.03.04.2_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.03.11_all_data.xls",
                 "C:\workspace\FRA-UAS\semester3\ML-AIS\ML-AIS-Sensor-Project-2021\Programs\MATLAB\Classification/data/2022.04.14_all_data.xls"]


for item in range(len(data_path_arr)):

    print(len(data_path_arr))
    print(data_path_arr[0])

    data = pd.read_excel(data_path_arr[item], header=None)
    # data = pd.read_excel(data_path, header=None) # all data without headers
    # label = pd.read_excel(label_path, header=None) # all label with same index to data

    # data = data[0:2000]

    print("finished reading data ...")

    # 1.    Create Images
    # h: height , w: width
    # channel : R, G, B
    h = 10
    w = h
    # mat = np.zeros((h,w), np.uint8)
    mat = np.zeros((h, w, 3), np.uint8)

    data_padding = np.zeros((1, h*w), np.uint8)

    rows = len(data)  # rows
    cols = len(data.columns)  # columns

    for i in range(rows):
        # padding data
        if h*w > cols:
            data_padding[0, 0:cols] = data.iloc[i, :]
            data_padding[0, cols+1:h*w-1] = 0  # padding with zeros

        # normalize data
        norm_data = data_padding/1000
        data_padding = 255*norm_data

        # skip if imag exist
        img_path = folder_name[item]+"/"+str(i)+".png"
        if os.path.exists(img_path):
            print(img_path+" already exist")
            continue

        for j in range(h):

            if j == 0:
                begin_idx = 0
            else:
                begin_idx = j*w

            end_idx = (j+1)*w

            # mat[j, :] = data_padding[0][begin_idx:end_idx]
            mat[j, :, 0] = data_padding[0][begin_idx:end_idx]
            mat[j, :, 1] = data_padding[0][begin_idx:end_idx]
            mat[j, :, 2] = data_padding[0][begin_idx:end_idx]

        X = np.arange(0, 10, 1, dtype=int)
        Y = np.arange(0, 10, 1, dtype=int)

        fig, ax = plt.subplots(1, 1)

        # contour plot color
        # cp = ax.contourf(X, Y, mat[:, :, 0])

        # plot greyscale
        plt.imshow(mat)

        if os.path.exists(folder_name[item]) == False:
            os.mkdir(folder_name[item])

        ax = plt.gca()
        ax.set_axis_off()
        # plt.show()
        plt.subplots_adjust(top=1, bottom=0, right=1, left=0, hspace=0, wspace=0)
        plt.margins(0, 0)
        plt.axis('off')
        # plt.figure(figsize=(1, 1), dpi=100)
        fig.set_size_inches(1, 1)
        plt.savefig(img_path, format='png', dpi=100)
        plt.close()

        print("finished writing file: "+img_path)

    print("end of program")
