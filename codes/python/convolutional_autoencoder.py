import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import matplotlib.pyplot as plt

# ================= DATA =================
Nx = 500
Nmu = 200

xx = np.linspace(0, 1, Nx)
mus = np.linspace(1, 3, Nmu)

XX, MM = np.meshgrid(xx, mus, indexing='ij')

def y_exact(x, mu):
    return (1 + np.log(mu)) * (x < (mu / 4))# np.exp(-(100*(x-mu/4))**2) #

yy = y_exact(XX, MM)   # shape: (Nx, Nmu)

# Convert to tensor: [batch, channel, length]
data = torch.tensor(yy.T, dtype=torch.float32).unsqueeze(1)  # (Nmu,1,500)

# ================= MODEL =================
latent_dim = 3

class ConvAutoencoder(nn.Module):
    def __init__(self):
        super().__init__()

        # ===== ENCODER =====
        self.encoder = nn.Sequential(
            nn.Conv1d(1, 4, 4, stride=2, padding=1),  # 500 → 250
            nn.LeakyReLU(),

            nn.Conv1d(4, 8, 4, stride=2, padding=1),  # 250 → 125
            nn.Tanh(),

            nn.Conv1d(8, 8, 4, stride=2, padding=1),  # 125 → 62
            nn.Tanh(),

            nn.Conv1d(8, 8, 4, stride=2, padding=1),  # 62 → 31
            nn.Tanh(),

            nn.Conv1d(8, 8, 4, stride=2, padding=1),  # 31 → 15
            nn.Tanh(),

            nn.Conv1d(8, 8, 4, stride=2, padding=1),  # 15 → 7
            nn.Tanh(),

            nn.Conv1d(8, 8, 4, stride=2, padding=1),  # 7 → 3
            nn.Tanh()
        )

        self.fc_enc = nn.Linear(3 * 8, latent_dim)
        self.fc_dec = nn.Linear(latent_dim, 3 * 8)

        # ===== DECODER =====
        self.decoder = nn.Sequential(
            nn.ConvTranspose1d(8, 8, 4, stride=2, padding=0),  # 3 → 8
            nn.Tanh(),

            nn.ConvTranspose1d(8, 8, 4, stride=2, padding=1),  # 8 → 16
            nn.Tanh(),

            nn.ConvTranspose1d(8, 8, 4, stride=2, padding=1),  # 16 → 32
            nn.Tanh(),

            nn.ConvTranspose1d(8, 8, 4, stride=2, padding=2),  # 32 → 62
            nn.Tanh(),

            nn.ConvTranspose1d(8, 8, 4, stride=2, padding=1),  # 62 → 124
            nn.Tanh(),

            nn.ConvTranspose1d(8, 4, 4, stride=2, padding=0),  # 124 → 250
            nn.LeakyReLU(),

            nn.ConvTranspose1d(4, 1, 4, stride=2, padding=1)   # 250 → 500
        )

    def forward(self, x):
        x = self.encoder(x)
        x = x.view(x.size(0), -1)       # flatten
        z = self.fc_enc(x)
        x = self.fc_dec(z)
        x = x.view(-1, 8, 3)            # reshape
        x = self.decoder(x)
        return x, z

# ================= TRAINING =================
device = "cuda" if torch.cuda.is_available() else "cpu"
model = ConvAutoencoder().to(device)

criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=1e-3)

batch_size = 32
epochs = 5000  # (5000 is overkill in PyTorch)

dataset = torch.utils.data.TensorDataset(data, data)
loader = torch.utils.data.DataLoader(dataset, batch_size=batch_size, shuffle=True)

loss_history = []

for epoch in range(epochs):
    epoch_loss = 0
    for xb, yb in loader:
        xb, yb = xb.to(device), yb.to(device)

        optimizer.zero_grad()
        out, _ = model(xb)
        loss = criterion(out, yb)
        loss.backward()
        optimizer.step()

        epoch_loss += loss.item()

    epoch_loss /= len(loader)
    loss_history.append(epoch_loss)

    if epoch % 20 == 0:
        print(f"Epoch {epoch}, Loss {epoch_loss:.06e}")

# ================= LOSS PLOT =================
plt.figure()
plt.semilogy(loss_history)
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.grid()
plt.show()

# ================= TEST =================
Nmu_test = 10
mu_test = np.linspace(1.1, 2.9, Nmu_test)

test = np.array([y_exact(xx, mu) for mu in mu_test])
test = torch.tensor(test, dtype=torch.float32).unsqueeze(1).to(device)

with torch.no_grad():
    recon, Z = model(test)

recon = recon.cpu().numpy()
test = test.cpu().numpy()

# ================= PLOT =================
plt.figure()
for i in range(Nmu_test):
    plt.plot(xx, recon[i,0,:], 'b-')
    plt.plot(xx, test[i,0,:], 'r--')

plt.title("Autoencoder reconstruction")
plt.savefig("conv_autoncoder_predict.pdf")
plt.show()
