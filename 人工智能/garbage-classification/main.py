import torch
from torch import nn
import random 
import numpy as np
from PIL import Image 
from torchvision.transforms import transforms
import torchvision.transforms.functional as TF
import os
import torch.utils.data as Data
import torchvision
from torchvision import models

class MyCNN(nn.Module):
    """
    网络模型
    """
    def __init__(self, image_size, num_classes):
        super(MyCNN, self).__init__()
        # conv1: Conv2d -> BN -> ReLU -> MaxPool
        self.conv1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=16, kernel_size=3, stride=1, padding=1),
            nn.Conv2d(in_channels=16, out_channels=16, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(), 
            nn.MaxPool2d(kernel_size=2, stride=1),
        )
        # conv2: Conv2d -> BN -> ReLU -> MaxPool
        self.conv2 = nn.Sequential(
            nn.Conv2d(in_channels=16, out_channels=32, kernel_size=3, stride=1, padding=1),
            nn.Conv2d(in_channels=32, out_channels=32, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2),
        )
        self.conv3 = nn.Sequential(
            nn.Conv2d(in_channels=32, out_channels=64, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2),
        )
        self.conv4 = nn.Sequential(
            nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2),
        )
        self.conv5 = nn.Sequential(
            nn.Conv2d(in_channels=64, out_channels=128, kernel_size=3, stride=1, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=1),
        )
        # fully connected layer
        self.dp1 = nn.Dropout(0.20)
        self.fc1 = nn.Linear(4608, 256)
        self.dp2 = nn.Dropout(0.50)
        self.fc2 = nn.Linear(256, num_classes)

    def forward(self, x):
        """
        input: N * 3 * image_size * image_size
        output: N * num_classes
        """
        x = self.conv1(x)
        x = self.conv2(x)
        x = self.conv3(x)
        x = self.conv4(x)
        x = self.conv5(x)
        # view(x.size(0), -1): change tensor size from (N ,H , W) to (N, H*W)
        x = x.view(x.size(0), -1)
        ##x = self.dp1(x)
        x = self.fc1(x)
        ##x = self.dp2(x)
        output = self.fc2(x)
        return output



def getRsn():
    model = models.resnet18(pretrained=False)
    num_fc_in = model.fc.in_features
    model.fc = nn.Linear(num_fc_in, 6)
    return model

def getMbnet():
    model = models.mobilenet_v2(pretrained=True)
    print(model)
    model.classifier = nn.Sequential(
        nn.Linear(in_features=1280,out_features=64),
        nn.Dropout(p=0.5, inplace=False),
        nn.Linear(in_features=64,out_features=6,bias=True),
    )
    return model

def load_model(model_path, device):
    # net = getRsn()
    net = MyCNN(64, 6)
    ## net = getMbnet()
    print('loading the model from %s' % model_path)
    state_dict = torch.load(model_path, map_location=str(device))
    if hasattr(state_dict, '_metadata'):
        del state_dict._metadata
    net.load_state_dict(state_dict)
    return net 


# 加载模型,加载请注意 model_path 是相对路径, 与当前文件同级。
# 如果你的模型是在 results 文件夹下的 dnn.h5 模型，则 model_path = 'results/dnn.h5'
model_path = 'results/cnn.pth'
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = load_model(model_path, device).to(device)
model.eval()

def predict(img):
    """
    :param img: PIL.Image 对象
    :return: string, 模型识别图片的类别, 
            共 'cardboard','glass','metal','paper','plastic','trash' 6 个类别
    """
    transform = transforms.Compose([
                                ##transforms.RandomCrop(size=(384,512), padding=10),
                                transforms.Resize((64,64)),
                                transforms.ToTensor(),
                                transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
    ])
    img = transform(img)

    classes=['cardboard','glass','metal','paper','plastic','trash']

    img = img.to(device).unsqueeze(0)
    pred_cate = model(img)
    preds = pred_cate.argmax(dim=1)
    # -------------------------------------------------------------------------
    y_predict = classes[preds]

    # 返回图片的类别
    return y_predict
