# 🖼️ Imagens do App CCL Midas

## 📋 Instruções

### **Logo Principal (`logo.png`)**

Adicione sua logo aqui com o nome:
```
logo.png
```

**Usado em:**
- ✅ Tela de conexão (120x120px)
- ✅ Splash screen (centralizado)

**Especificações:**
- **Formato:** PNG (com transparência recomendado)
- **Tamanho recomendado:** 512x512 pixels ou maior
- **Proporção:** Quadrada (1:1) ou retangular
- **Fundo:** Transparente (recomendado para splash screen)

---

## 📁 Estrutura:

```
assets/images/
├── logo.png       ← Logo principal (conexão + splash)
└── README.md      ← Este arquivo
```

---

## 🎨 Dicas:

### **Para melhor resultado:**
- Use PNG com **fundo transparente**
- Tamanho ideal: **512x512** ou **1024x1024** pixels
- A logo ficará centralizada em fundo cinza escuro (#212121)
- Evite textos muito pequenos

### **Cores do app:**
- Fundo: `#212121` (cinza escuro - Colors.grey[900])
- Laranja: `#FF723A` (cor principal do CCL Midas)

---

## 🚀 Gerar Splash Screen:

Depois de adicionar o `logo.png`, execute:

```powershell
flutter pub get
flutter pub run flutter_native_splash:create
```

Isso vai gerar automaticamente a splash screen para Android e iOS!

---

**Desenvolvido para CCL Midas** 🎚️

