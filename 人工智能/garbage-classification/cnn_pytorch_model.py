###############################################################################
# 重要: 请务必把任务(jobs)中需要保存的文件存放在 results 文件夹内
# Important : Please make sure your files are saved to the 'results' folder
# in your jobs
###############################################################################
import torch
import torch.nn as nn
import torch.utils.data as Data
import torchvision
import time
import os
from torchvision import models
import matplotlib.pyplot as plt

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
        x = self.dp1(x)
        x = self.fc1(x)
        x = self.dp2(x)
        output = self.fc2(x)
        return output


def getRsn():
    model = models.resnet18(pretrained=True)
    num_fc_in = model.fc.in_features
    model.fc = nn.Linear(num_fc_in, 6)
    return model

def getMbnet():
    model = models.mobilenet_v2(pretrained=True)
    model.classifier = nn.Sequential(
        nn.Linear(in_features=1280,out_features=64),
        nn.Dropout(p=0.5,inplace=False),
        nn.Linear(in_features=64,out_features=6,bias=True),
    )
    return model

def train(model, train_loader, loss_func, optimizer, device):
    """
    训练模型
    train model using loss_fn and optimizer in an epoch.
    model: CNN networks
    train_loader: a Dataloader object with training data
    loss_func: loss function
    device: train on cpu or gpu device
    """
    total_loss = 0
    # train the model using minibatch
    for i, (images, targets) in enumerate(train_loader):
        images = images.to(device)
        targets = targets.to(device)

        # forward
        outputs = model(images)
        _,preds = torch.max(outputs.data,1)
        loss = loss_func(outputs, targets)

        # backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        total_loss += loss.item()
        if (i + 1) % 100 == 0:
            print ("Step [{}/{}] Train Loss: {:.4f} Train acc".format(i+1, len(train_loader), loss.item()))
    save_model(model, save_path="results/cnn.pth")
    return total_loss / len(train_loader)


def evaluate(model, val_loader, device, name):
    """
    评估模型
    model: CNN networks
    val_loader: a Dataloader object with validation data
    device: evaluate on cpu or gpu device
    return classification accuracy of the model on val dataset
    """
    # evaluate the model
    model.eval()
    # context-manager that disabled gradient computation
    with torch.no_grad():
        correct = 0
        total = 0
        
        for i, (images, targets) in enumerate(val_loader):
            # device: cpu or gpu
            images = images.to(device)
            targets = targets.to(device)
            outputs = model(images)

            # return the maximum value of each row of the input tensor in the 
            # given dimension dim, the second return vale is the index location
            # of each maxium value found(argmax)
            _, predicted = torch.max(outputs.data, dim=1)
            correct += (predicted == targets).sum().item()

            total += targets.size(0)

        accuracy = correct / total
        print('Accuracy on '+name+' Set: {:.4f} %'.format(100 * accuracy))
        return accuracy


def save_model(model, save_path="results/cnn.pth"):
    '''保存模型'''
    # save model
    torch.save(model.state_dict(), save_path)


def show_curve(ys, title):
    """
    plot curlve for Loss and Accuacy
    Args:
        ys: loss or acc list
        title: loss or accuracy
    """
    x = np.array(range(len(ys)))
    y = np.array(ys)
    plt.plot(x, y, c='b')
    plt.axis()
    plt.title('{} curve'.format(title))
    plt.xlabel('epoch')
    plt.ylabel('{}'.format(title))
    plt.show()


def fit(model, num_epochs, optimizer, device):
    """
    train and evaluate an classifier num_epochs times.
    We use optimizer and cross entropy loss to train the model. 
    Args: 
        model: CNN network
        num_epochs: the number of training epochs
        optimizer: optimize the loss function
    """

    # loss and optimizer
    loss_func = nn.CrossEntropyLoss()
    model.to(device)
    loss_func.to(device)

    # log train loss and test accuracy
    losses = []
    accs = []
    accst = []

    for epoch in range(num_epochs):

        print('Epoch {}/{}:'.format(epoch + 1, num_epochs))
        # train step
        loss = train(model, train_loader, loss_func, optimizer, device)
        losses.append(loss)

        # evaluate step
        accuracy = evaluate(model, test_loader, device, 'test')
        accuracy1 = evaluate(model, train_loader, device, 'train')
        accs.append(accuracy)
        accst.append(accuracy1)


    # show curve
    show_curve(losses, "train loss")
    show_curve(accs, "test accuracy")
    show_curve(accst, "train accuracy")

# model = models.vgg16_bn(pretrained=True)

# model_ft= models.resnet18(pretrained=True)

import numpy as np
import torch
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
import torch.nn.functional as F
import torch
from torchvision import datasets, transforms
from torch.utils import model_zoo
from torch.optim import lr_scheduler

# #hyper parameter
batch_size = 20
num_epochs = 10
lr = 0.00007
num_classes = 6
image_size = 64

path = "datasets/la1ji1fe1nle4ishu4ju4ji22-momodel/dataset-resized"
transform = transforms.Compose([
    transforms.Resize((64,64)),
    transforms.RandomRotation((30,30)),
    transforms.RandomVerticalFlip(0.1),
    transforms.RandomGrayscale(0.1),
    transforms.ToTensor(),
    transforms.Normalize((0.5,0.5,0.5),(0.5,0.5,0.5))])

dataset = datasets.ImageFolder(path, transform=transform)

print("dataset.classes",dataset.classes)
print("dataset.class_to_idx",dataset.class_to_idx)
idx_to_class = dict((v, k) for k, v in dataset.class_to_idx.items())
print("idx_to_class",idx_to_class)
print('len(dataset)', len(dataset))

"""将训练集划分为训练集和验证集"""
train_db, val_db = torch.utils.data.random_split(dataset, [2257, 270])
print('train:', len(train_db), 'validation:', len(val_db))

# 训练集
train_loader = torch.utils.data.DataLoader(
    train_db,
    batch_size=batch_size,
    shuffle=True, 
    drop_last=False)
test_loader = torch.utils.data.DataLoader(
    val_db,
    batch_size=batch_size,
    shuffle=True)

classes = set(['cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'])

# declare and define an objet of MyCNN
mycnn = MyCNN(image_size, num_classes)
# mycnn = getRsn()
# mycnn = getMbnet()
print(mycnn)
# device = torch.device('cuda:0')
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

optimizer = torch.optim.Adam(mycnn.parameters(), lr=lr)

# start training on cifar10 dataset
fit(mycnn, num_epochs, optimizer, device)