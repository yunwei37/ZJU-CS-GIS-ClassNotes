from matplotlib import pyplot as plt  # 展示图片
import numpy as np  # 数值处理
import cv2  # opencv库
from sklearn.linear_model import LinearRegression, Ridge, Lasso  # 回归分析

def noise_mask_image(img, noise_ratio):
    """
    根据题目要求生成受损图片
    :param img: 图像矩阵，一般为 np.ndarray
    :param noise_ratio: 噪声比率，可能值是0.4/0.6/0.8
    :return: noise_img 受损图片, 图像矩阵值 0-1 之间，数据类型为 np.array, 
             数据类型对象 (dtype): np.double, 图像形状:(height,width,channel),通道(channel) 顺序为RGB
    """
    # 受损图片初始化
    noise_img = None
    
    # -------------实现受损图像答题区域-----------------
    import random
    print(img.shape)
    noise_img = np.copy(img)
    for i in range(3):
        for j in range(img.shape[0]):
            mask = list(range(img.shape[1]))
            mask = random.sample(mask, int(img.shape[1]*noise_ratio))
            for k in range(img.shape[1]):
                if k in mask:
                    noise_img[j,k,i] = 0
                    
            

    # -----------------------------------------------

    return noise_img

def get_noise_mask(noise_img):
    """
    获取噪声图像，一般为 np.array
    :param noise_img: 带有噪声的图片
    :return: 噪声图像矩阵
    """
    # 将图片数据矩阵只包含 0和1,如果不能等于 0 则就是 1。
    return np.array(noise_img != 0, dtype='double')

def get_window(res_img,noise_mask,sc,i,j,k):
    listx = []
                 
    if i-sc >= 0:
        starti = i-sc 
    else:
        starti = 0
    if j+1 <= res_img.shape[1]-1 and noise_mask[0,j+1,k] !=0:
        listx.append(res_img[0,j+1,k])
    if j-1 >=0 and noise_mask[0,j-1,k] !=0:
        listx.append(res_img[0,j-1,k])
                    
    if i+sc <= res_img.shape[0]-1:
        endi = i+sc
    else:
        endi = res_img.shape[0]-1
    if j+1 <= res_img.shape[1]-1 and noise_mask[endi,j+1,k] !=0:
        listx.append(res_img[endi,j+1,k])
    if j-1 >=0 and noise_mask[endi,j-1,k] !=0:
        listx.append(res_img[endi,j-1,k])
                        
    if j+sc <= res_img.shape[1]-1:
        endj = j+sc
    else:
        endj = res_img.shape[1]-1
    if i+1 <= res_img.shape[0]-1 and noise_mask[i+1,endj,k] !=0:
        listx.append(res_img[i+1,endj,k])
    if i-1 >=0 and noise_mask[i-1,endj,k] !=0:
        listx.append(res_img[i-1,endj,k])
                    
    if j-sc >= 0:
        startj = j-sc
    else:
        startj = 0
    if i+1 <= res_img.shape[0]-1 and noise_mask[i+1,0,k] !=0:
        listx.append(res_img[i+1,0,k])
    if i-1 >=0 and noise_mask[i-1,0,k] !=0:
        listx.append(res_img[i-1,0,k])
                                        
    for m in range(starti,endi+1):
        for n in range(startj,endj+1):
            if noise_mask[m,n,k] != 0:
                listx.append(res_img[m,n,k])
    listx.sort()
    return listx

def get_window_small(res_img,noise_mask,i,j,k):
    listx = []
    sc = 1             
    if i-sc >= 0 and noise_mask[i-1,j,k]!=0:
        listx.append(res_img[i-1,j,k])

    if i+sc <= res_img.shape[0]-1 and noise_mask[i+1,j,k]!=0:
        listx.append(res_img[i+1,j,k])
                        
    if j+sc <= res_img.shape[1]-1 and noise_mask[i,j+1,k]!=0:
        listx.append(res_img[i,j+1,k])
                    
    if j-sc >= 0 and noise_mask[i,j-1,k]!=0:
        listx.append(res_img[i,j-1,k])
    listx.sort()
    return listx

def restore_image(noise_img, size=4):
    """
    使用 你最擅长的算法模型 进行图像恢复。
    :param noise_img: 一个受损的图像
    :param size: 输入区域半径，长宽是以 size*size 方形区域获取区域, 默认是 4
    :return: res_img 恢复后的图片，图像矩阵值 0-1 之间，数据类型为 np.array,
            数据类型对象 (dtype): np.double, 图像形状:(height,width,channel), 通道(channel) 顺序为RGB
    """
    # 恢复图片初始化，首先 copy 受损图片，然后预测噪声点的坐标后作为返回值。
    res_img = np.copy(noise_img)

    # 获取噪声图像
    noise_mask = get_noise_mask(noise_img)
    # -------------实现图像恢复代码答题区域----------------------------
    for i in range(noise_mask.shape[0]):
        for j in range(noise_mask.shape[1]):
            for k in range(noise_mask.shape[2]):
                if noise_mask[i,j,k] == 0:
                    sc = 1
                    listx = get_window_small(res_img,noise_mask,i,j,k)
                    if len(listx) != 0:
                        res_img[i,j,k] = listx[len(listx)//2]
                    else:
                        while(len(listx) == 0):
                            listx = get_window(res_img,noise_mask,sc,i,j,k)
                            sc = sc+1
                        res_img[i,j,k] = listx[len(listx)//2]
                    
    # ---------------------------------------------------------------

    return res_img