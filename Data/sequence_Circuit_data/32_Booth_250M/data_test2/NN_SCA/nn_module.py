import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader, random_split
from sklearn.preprocessing import StandardScaler
import torch.optim as optim
import matplotlib.pyplot as plt
import time

# ===== Dataset Loader =====
class BoothDataset(Dataset):
    def __init__(self, x_path, y_path, normalize=True):
        self.X = np.load(x_path)
        self.Y = np.load(y_path)

        if normalize:
            self.scaler = StandardScaler()
            self.X = self.scaler.fit_transform(self.X)

        self.X = torch.tensor(self.X, dtype=torch.float32)
        self.Y = torch.tensor(self.Y, dtype=torch.long)

    def __len__(self):
        return len(self.X)

    def __getitem__(self, idx):
        return self.X[idx], self.Y[idx]

# ===== Multi-Cycle CNN Model =====
class BoothMultiCycleNet(nn.Module):
    def __init__(self, input_dim=140, num_cycles=16, num_classes=5):
        super().__init__()
        self.shared_cnn = nn.Sequential(
            nn.Conv1d(1, 32, kernel_size=5, padding=2),
            nn.ReLU(),
            nn.MaxPool1d(2),
            nn.Conv1d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool1d(2),
            nn.Flatten()
        )

        dummy_input = torch.zeros(1, 1, input_dim)
        dummy_out = self.shared_cnn(dummy_input)
        feature_dim = dummy_out.shape[1]

        self.heads = nn.ModuleList([
            nn.Linear(feature_dim, num_classes) for _ in range(num_cycles)
        ])

    def forward(self, x):
        x = x.unsqueeze(1)  # (B, 1, 140)
        features = self.shared_cnn(x)
        outputs = [head(features) for head in self.heads]  # list of (B, num_classes)
        return torch.stack(outputs, dim=1)  # (B, 16, num_classes)

# ===== 训练函数 =====
def train_model(model, dataloader, device, epochs=10, lr=1e-3):
    model.to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=lr)

    for epoch in range(epochs):
        model.train()
        epoch_loss = 0
        correct = 0
        total = 0

        for batch_x, batch_y in dataloader:
            batch_x, batch_y = batch_x.to(device), batch_y.to(device)
            optimizer.zero_grad()
            outputs = model(batch_x)  # (B, 16, 5)

            loss = sum(criterion(outputs[:, i], batch_y[:, i]) for i in range(16)) / 16
            loss.backward()
            optimizer.step()

            epoch_loss += loss.item()

            preds = outputs.argmax(dim=2)  # (B, 16)
            correct += (preds == batch_y).sum().item()
            total += batch_y.numel()

        acc = correct / total * 100
        print(f"Epoch {epoch+1}/{epochs} | Loss: {epoch_loss:.4f} | Accuracy: {acc:.2f}%")

# ===== 主程序 =====
if __name__ == '__main__':
    # 加载完整数据集
    dataset = BoothDataset('Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/X_traces.npy', 'Data/sequence_Circuit_data/32_Booth_250M/data_test2/produced_data/Y_booth_labels.npy', normalize=True)
    
    # 设置训练集和测试集的比例
    train_size = int(0.9 * len(dataset))  # 90%用于训练
    test_size = len(dataset) - train_size  # 10%用于测试
    
    # 随机划分数据集
    train_dataset, test_dataset = random_split(
        dataset, 
        [train_size, test_size],
        generator=torch.Generator().manual_seed(42)  # 设置随机种子以确保可重复性
    )
    
    # 创建数据加载器
    train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=64, shuffle=False)
    
    # 打印数据集大小
    print(f"总数据集大小: {len(dataset)}")
    print(f"训练集大小: {len(train_dataset)}")
    print(f"测试集大小: {len(test_dataset)}")
    
    # 初始化模型
    model = BoothMultiCycleNet()
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # 修改训练函数，添加测试集评估
    def train_and_evaluate(model, train_loader, test_loader, device, epochs=20, lr=1e-3):
        model.to(device)
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.Adam(model.parameters(), lr=lr)
        
        # 用于存储训练过程中的指标
        history = {
            'train_loss': [],
            'train_acc': [],
            'test_loss': [],
            'test_acc': []
        }
        
        for epoch in range(epochs):
            # 训练阶段
            model.train()
            train_loss = 0
            train_correct = 0
            train_total = 0
            
            for batch_x, batch_y in train_loader:
                batch_x, batch_y = batch_x.to(device), batch_y.to(device)
                optimizer.zero_grad()
                outputs = model(batch_x)
                
                loss = sum(criterion(outputs[:, i], batch_y[:, i]) for i in range(16)) / 16
                loss.backward()
                optimizer.step()
                
                train_loss += loss.item()
                preds = outputs.argmax(dim=2)
                train_correct += (preds == batch_y).sum().item()
                train_total += batch_y.numel()
            
            train_loss = train_loss / len(train_loader)
            train_acc = train_correct / train_total * 100
            
            # 测试阶段
            model.eval()
            test_loss = 0
            test_correct = 0
            test_total = 0
            
            with torch.no_grad():
                for batch_x, batch_y in test_loader:
                    batch_x, batch_y = batch_x.to(device), batch_y.to(device)
                    outputs = model(batch_x)
                    
                    loss = sum(criterion(outputs[:, i], batch_y[:, i]) for i in range(16)) / 16
                    test_loss += loss.item()
                    
                    preds = outputs.argmax(dim=2)
                    test_correct += (preds == batch_y).sum().item()
                    test_total += batch_y.numel()
            
            test_loss = test_loss / len(test_loader)
            test_acc = test_correct / test_total * 100
            
            # 存储当前epoch的指标
            history['train_loss'].append(train_loss)
            history['train_acc'].append(train_acc)
            history['test_loss'].append(test_loss)
            history['test_acc'].append(test_acc)
            
            print(f"Epoch {epoch+1}/{epochs}")
            print(f"Training Loss: {train_loss:.4f} | Training Accuracy: {train_acc:.2f}%")
            print(f"Testing Loss: {test_loss:.4f} | Testing Accuracy: {test_acc:.2f}%")
            print("-" * 50)
        
        # 绘制训练过程的曲线图
        plt.figure(figsize=(12, 4))
        
        # 损失曲线
        plt.subplot(1, 2, 1)
        plt.plot(history['train_loss'], label='Training Loss')
        plt.plot(history['test_loss'], label='Testing Loss')
        plt.title('Model Loss')
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.legend()
        plt.grid(True)
        
        # 准确率曲线
        plt.subplot(1, 2, 2)
        plt.plot(history['train_acc'], label='Training Accuracy')
        plt.plot(history['test_acc'], label='Testing Accuracy')
        plt.title('Model Accuracy')
        plt.xlabel('Epoch')
        plt.ylabel('Accuracy (%)')
        plt.legend()
        plt.grid(True)
        
        plt.tight_layout()
        plt.savefig('training_history.png')
        plt.show()
        
        return history
    
    # 开始训练和评估
    history = train_and_evaluate(model, train_loader, test_loader, device, epochs=20)

