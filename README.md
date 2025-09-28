# Monad Dog - Multi-Network Farcaster Mini App

Bu proje, hem Monad Testnet hem de Base Mainnet üzerinde çalışan bir Farcaster mini app'idir. Kullanıcılar ağ seçimi yapabilir ve her iki ağda da aynı oyun deneyimini yaşayabilirler.

## 🚀 Özellikler

### Oyun Mekanikleri
- **🐕 Pet Dog**: Köpeği sev ve 10 XP kazan
- **👋 Greet**: GM/GN söyle ve 5 XP kazan  
- **🪙 Flip Coin**: Yazı-tura at ve 3 XP kazan
- **🎰 Slots**: Slot makinesi oyna ve büyük ödüller kazan
- **💰 Claim**: XP'ni $DOG tokenlarına çevir

### Ağ Desteği
- **Monad Testnet**: Tam fonksiyonel (kontratlar deploy edilmiş)
- **Base Mainnet**: Hazır (kontratlar deploy edilmeyi bekliyor)

## 🔧 Kurulum

1. Projeyi klonlayın
2. `index.html` dosyasını bir web sunucusunda çalıştırın
3. Farcaster'da frame olarak kullanın

## 📝 Base Mainnet Kontrat Deployment

Base ağında çalışması için aşağıdaki kontratları deploy etmeniz gerekiyor:

### Gerekli Kontratlar
1. **Pet Contract** - `pet()` fonksiyonu
2. **Greet Contract** - `gm()` ve `gn()` fonksiyonları  
3. **Flip Contract** - `flip()` fonksiyonu
4. **Slots Contract** - `buyCredits()`, `playSlots()`, `getCredits()` fonksiyonları
5. **DOG Token Contract** - `claim()`, `balanceOf()` fonksiyonları

### Kontrat Adreslerini Güncelleme

`index.html` dosyasında `NETWORKS.base.contracts` bölümünde placeholder adresleri gerçek adreslerle değiştirin:

```javascript
contracts: {
  PET: "0x...", // Gerçek Pet kontrat adresi
  GREET: "0x...", // Gerçek Greet kontrat adresi
  FLIP: "0x...", // Gerçek Flip kontrat adresi
  SLOTS: "0x...", // Gerçek Slots kontrat adresi
  DOG_TOKEN: "0x..." // Gerçek DOG Token kontrat adresi
}
```

## 🎮 Oyun Mekanikleri

### XP Sistemi
- Her ağ için XP ayrı ayrı tutulur
- XP localStorage ve Supabase'de saklanır
- Ağ değiştirildiğinde XP'ler izole kalır

### Token Sistemi
- 10 XP = 1 $DOG Token
- Tokenlar claim edildikten sonra XP sıfırlanır
- Her ağ için token balance ayrı tutulur

### Slots Oyunu
- **Monad**: 0.1 MONAD = 2 oyun kredisi
- **Base**: 0.001 ETH = 2 oyun kredisi
- 4 aynı sembol = 5000 XP (JACKPOT!)
- 3 aynı sembol = 500 XP
- 2 aynı sembol = 50 XP

## 🔗 Ağ Yapılandırması

### Monad Testnet
- Chain ID: 10143 (0x279F)
- RPC: https://testnet-rpc.monad.xyz
- Explorer: https://testnet.monadscan.com/
- Currency: MONAD

### Base Mainnet  
- Chain ID: 8453 (0x2105)
- RPC: https://mainnet.base.org
- Explorer: https://basescan.org/
- Currency: ETH

## 🛠️ Geliştirme

### Ağ Ekleme
Yeni bir ağ eklemek için `NETWORKS` objesine yeni bir entry ekleyin:

```javascript
newNetwork: {
  name: 'Network Name',
  chainId: '0x...',
  rpcUrl: 'https://...',
  blockExplorer: 'https://...',
  nativeCurrency: {
    name: 'Currency Name',
    symbol: 'SYMBOL',
    decimals: 18
  },
  contracts: {
    PET: "0x...",
    GREET: "0x...",
    FLIP: "0x...",
    SLOTS: "0x...",
    DOG_TOKEN: "0x..."
  }
}
```

### State Management
- XP ve credits her ağ için ayrı tutulur
- localStorage key formatı: `{address}_{network}`
- Supabase'de de aynı format kullanılır

## 📱 Farcaster Entegrasyonu

- Farcaster Mini App SDK kullanılır
- Frame manifest desteği
- Paylaşım fonksiyonları
- Wallet entegrasyonu

## 🎯 Sonraki Adımlar

1. Base ağında kontratları deploy edin
2. Kontrat adreslerini güncelleyin
3. Test edin ve yayınlayın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
