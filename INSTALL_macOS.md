# 📱 MiAjudAI - Guia Completo de Instalação para macOS

**Data:** 26 de Maio de 2026
**Público:** Desenvolvedores em Macbook Air
**Objetivo:** Setup completo para rodar Backend + Frontend

---

## ✅ Checklist de Verificação Rápida

```bash
# Execute para verificar o que já está instalado:
node --version      # Deve ser ≥18.0.0
npm --version       # Deve ser ≥9.0.0
docker --version    # Opcional, mas recomendado
flutter --version   # Deve estar instalado
dart --version      # Vem com Flutter
git --version       # Deve estar instalado
```

---

## 1️⃣ **Pré-requisitos (Ferramentas Base)**

### **1.1 Homebrew** (Gerenciador de Pacotes para macOS)
```bash
# Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Adicionar ao PATH (só se você usar Apple Silicon M1/M2/M3)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

# Verificar
brew --version
```

### **1.2 Git** (Versionamento)
```bash
# Instalar via Homebrew
brew install git

# Configurar (usar seu e-mail/nome)
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Verificar
git --version
```

---

## 2️⃣ **Backend Setup (Node.js + Express + PostgreSQL)**

### **2.1 Node.js & npm**

#### **Opção A: Instalar via Homebrew (Recomendado)**
```bash
brew install node@18

# Verificar versão
node --version    # Deve ser v18.x.x
npm --version     # Deve ser ≥9.0.0

# Se npm não estiver ≥9.0.0, atualizar:
npm install -g npm@latest
```

#### **Opção B: Instalar via nvm (Node Version Manager)** ⭐ *Mais Flexível*
```bash
# 1. Instalar nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 2. Adicionar ao shell config (abrir novo terminal depois)
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zprofile
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zprofile
source ~/.zprofile

# 3. Instalar Node.js 18
nvm install 18
nvm use 18
nvm alias default 18

# 4. Verificar
node --version    # v18.x.x
npm --version     # ≥9.0.0
```

### **2.2 Docker & Docker Compose**

#### **Opção A: Desktop (Recomendado para macOS)**
1. Baixar: https://www.docker.com/products/docker-desktop
2. Clicar em `.dmg` e instalar na pasta Applications
3. Abrir Docker Desktop (vai aparecer na barra superior)
4. Aguardar inicializar (~1-2 min)

#### **Opção B: Instalar via Homebrew**
```bash
brew install docker docker-compose

# Instalar Docker Desktop via brew cask
brew install --cask docker

# Verificar
docker --version
docker-compose --version
```

#### **Verificação Final**
```bash
docker run hello-world  # Deve retornar "Hello from Docker!"
```

### **2.3 PostgreSQL (Via Docker)**

No projeto já há `docker-compose.yml` configurado. Basta rodar:

```bash
cd backend

# Iniciar PostgreSQL
docker-compose up -d

# Verificar se está rodando
docker-compose ps
# Deve mostrar: miajudai_postgres ... Up

# Parar quando necessário
docker-compose down

# Ver logs
docker-compose logs -f postgres
```

**Credenciais Padrão (do docker-compose.yml):**
```
Host: localhost
Port: 5432
Database: miajudai_dev
User: postgres
Password: postgres
```

### **2.4 Dependências Node.js**

```bash
cd backend

# Instalar todas as dependências
npm install

# Verificar se funcionou
npm list | head -20
```

### **2.5 Variáveis de Ambiente Backend**

```bash
cd backend

# Criar arquivo .env baseado no exemplo
cp .env.example .env

# EDITAR .env com suas credenciais:
nano .env  # ou abrir em editor (VS Code, etc)
```

**Variáveis essenciais para dev:**
```bash
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=miajudai_dev

# Firebase Admin SDK (obter em Firebase Console)
FIREBASE_PROJECT_ID=seu-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@seu-project-id.iam.gserviceaccount.com

# JWT
JWT_SECRET=sua_chave_secreta_muito_longa_minimo_32_caracteres

# OpenAI (opcional, get em openai.com)
OPENAI_API_KEY=sk-xxxxx

# Twilio (opcional, para SMS)
TWILIO_ACCOUNT_SID=xxxxx
TWILIO_AUTH_TOKEN=xxxxx
TWILIO_PHONE_NUMBER=+1234567890

# Node
NODE_ENV=development
PORT=5000
```

### **2.6 Iniciar Backend**

```bash
cd backend

# Dev mode (com auto-reload)
npm run dev

# Deve aparecer:
# [backend] Server running on http://localhost:5000
# [backend] Database connected
```

### **2.7 Health Check Backend**

Em outro terminal:
```bash
curl http://localhost:5000/health

# Resposta esperada:
# {"status":"ok","timestamp":"2026-05-26T..."}
```

---

## 3️⃣ **Frontend Setup (Flutter)**

### **3.1 Flutter & Dart**

#### **Opção A: Instalar via Homebrew**
```bash
brew install flutter

# Verificar
flutter --version
dart --version
```

#### **Opção B: Instalar Manualmente** (Se não funcionar via Homebrew)

1. Baixar: https://flutter.dev/docs/get-started/install/macos
2. Extrair para `~/development/flutter` (criar pasta se não existir)
3. Adicionar ao PATH:
```bash
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zprofile
source ~/.zprofile
```

4. Verificar:
```bash
flutter --version
flutter doctor  # Mostra o que está faltando
```

### **3.2 Android Studio (Para emulador/build Android)**

```bash
# Instalar via Homebrew
brew install --cask android-studio

# Ou baixar manualmente: https://developer.android.com/studio
```

**Depois de instalar:**
1. Abrir Android Studio
2. Menu: Tools → SDK Manager
3. Marcar:
   - ✅ Android SDK Platform 31+ (mínimo)
   - ✅ Android SDK Tools
   - ✅ Android Emulator
4. Clicar "Apply" e aguardar instalação (~2GB)

### **3.3 Configurar Emulador Android**

```bash
# Listar AVDs (Android Virtual Devices) disponíveis
flutter emulators

# Se nenhum, criar novo via Android Studio:
# Tools → AVD Manager → Create Virtual Device
# Escolher: Pixel 4a + Android 13+

# Iniciar emulador
flutter emulators --launch <avd-name>
# Ex: flutter emulators --launch Pixel_4a_API_33

# Verificar dispositivos conectados
flutter devices
# Deve aparecer: emulator-5554 • Android emulator
```

### **3.4 Dependências Flutter**

```bash
cd frontend

# Instalar dependências
flutter pub get

# Verificar
flutter doctor

# Se aparecer warnings, resolver (geralmente é só confirmar acordos do Android)
```

### **3.5 Variáveis de Ambiente Frontend**

O arquivo `frontend/assets/.env` é **gerado automaticamente** pelo script `backend/scripts/setup-env.js` quando você rodar:
```bash
cd backend
npm run dev  # ou npm start
```

Isso detecta seu IP local e escreve a URL do backend no frontend.

**Se precisar configurar manualmente:**
```bash
# Criar arquivo (macOS)
cat > frontend/assets/.env << EOF
API_BASE_URL=http://192.168.x.x:5000
EOF

# Substituir 192.168.x.x pelo seu IP local
# Descobrir IP: ifconfig | grep "inet " (procure por 192.168... ou 10.0...)
```

### **3.6 Iniciar Frontend**

```bash
cd frontend

# Modo desenvolvimento (com hot reload)
flutter run

# Depois de compilar (~1-2 min na primeira vez):
# Aplicativo abre no emulador
# Pressione 'r' para hot reload
# Pressione 'R' para hot restart
```

**Comandos úteis no modo flutter run:**
```
r     → Hot reload (mudanças no código sem reiniciar app)
R     → Hot restart (reinicia tudo)
q     → Sair
h     → Help
```

---

## 4️⃣ **Testes & Verificação Completa**

### **4.1 Backend - Testes Automatizados**

```bash
cd backend

# Rodar todos os testes
npm test

# Com cobertura
npm test -- --coverage

# Modo watch (re-roda ao salvar)
npm run test:watch
```

### **4.2 Linting (Backend)**

```bash
cd backend

# Checar estilo
npm run lint

# Corrigir automaticamente
npm run lint:fix
```

### **4.3 Frontend - Testes**

```bash
cd frontend

# Rodar testes
flutter test

# Modo watch
flutter test --watch

# Coverage
flutter test --coverage
```

### **4.4 Full Integration Test (Recomendado)**

```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend (esperar backend iniciar)
cd frontend
flutter run

# Terminal 3: Teste as APIs
curl -X GET http://localhost:5000/health
# Deve retornar: {"status":"ok",...}

# No app Flutter:
# 1. Fazer login com Google/Apple
# 2. Navegar em Home, Calendário, Finanças
# 3. Enviar mensagem no chat
# 4. Verificar no console do backend que recebeu
```

---

## 5️⃣ **Build para Produção**

### **5.1 Android APK**

```bash
cd frontend

# Debug APK
flutter build apk --debug
# Gera: build/app/outputs/flutter-apk/app-debug.apk

# Release APK (otimizado)
flutter build apk --release
# Gera: build/app/outputs/flutter-apk/app-release.apk
```

### **5.2 Play Store (Futura)**

```bash
# Gerar App Bundle (formato oficial Google)
flutter build appbundle --release

# Gera: build/app/outputs/bundle/release/app-release.aab
# Fazer upload em: https://play.google.com/console
```

---

## 🐛 **Troubleshooting Comum - macOS**

### **❌ "flutter: command not found"**
```bash
# Adicionar ao PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zprofile
source ~/.zprofile
```

### **❌ "docker: command not found" (após instalar Docker Desktop)**
```bash
# Abrir Docker Desktop primeiro
open /Applications/Docker.app

# Ou aguardar ele iniciar automaticamente
# Depois rodar: docker version
```

### **❌ PostgreSQL não conecta**
```bash
# Verificar se container está rodando
docker-compose ps

# Se não estiver:
cd backend
docker-compose up -d

# Ver logs de erro
docker-compose logs postgres
```

### **❌ Frontend não encontra API (erro "Connection refused")**
```bash
# Verificar IP local
ifconfig | grep "inet "

# Editar frontend/assets/.env com o IP correto
# Exemplo: API_BASE_URL=http://192.168.1.100:5000

# Hot restart
# No terminal do flutter run, pressione: R
```

### **❌ Emulador muito lento (M1/M2 Macs)**
```bash
# Usar Android emulator com aceleração:
flutter emulators --launch <avd-name>

# Ou testar em iPhone emulator (Xcode)
# Mas esse projeto é Android-first
```

### **❌ "npm ERR! code EACCES" ao instalar**
```bash
# Não usar sudo! Em vez disso, usar nvm:
nvm install-latest-npm

# Ou limpar cache:
npm cache clean --force
npm install
```

---

## 📋 **Checklist Final - Tudo Funcionando?**

- [ ] ✅ Node.js ≥18.0.0 instalado
- [ ] ✅ npm ≥9.0.0 instalado
- [ ] ✅ Docker Desktop aberto e rodando
- [ ] ✅ PostgreSQL em container (docker-compose up -d)
- [ ] ✅ Backend: `npm install` completado
- [ ] ✅ Backend: `.env` configurado com credenciais
- [ ] ✅ Backend: `npm run dev` mostra "Server running on http://localhost:5000"
- [ ] ✅ Backend: `curl http://localhost:5000/health` retorna status ok
- [ ] ✅ Flutter instalado e `flutter --version` funciona
- [ ] ✅ Android Studio + Emulator configurado
- [ ] ✅ Frontend: `flutter pub get` completado
- [ ] ✅ Frontend: `flutter devices` mostra emulador
- [ ] ✅ Frontend: `flutter run` abre app no emulador
- [ ] ✅ Consegue fazer login no app

---

## 🚀 **Próximas Etapas**

Depois de tudo instalado e funcionando:

1. **Ler CLAUDE.md** - Arquitetura e padrões do projeto
2. **Rodar Migrações** - `npm run migrate` (backend)
3. **Seed Dados** - `npm run seed` (dados iniciais)
4. **Explorar Código** - Começar pelas rotas (`backend/src/routes`)
5. **Documentação API** - Usar Postman/Insomnia para testar endpoints

---

## 📞 **Suporte**

Se tiver problemas específicos:

1. **Verificar logs:**
   ```bash
   # Backend
   cd backend && npm run dev 2>&1 | tee backend.log

   # Frontend
   cd frontend && flutter run -v 2>&1 | tee frontend.log
   ```

2. **GitHub Issues** - Documentar o erro com:
   - Output do `flutter doctor`
   - Output do erro
   - `node --version` e `npm --version`
   - `docker --version`

3. **Slack/Discord** - Contactar equipe de dev

---

**Documento atualizado:** 26 de Maio de 2026
**Compatível com:** macOS 12+ (Intel & Apple Silicon)
**Mantém-se atualizado com:** MiAjudAI v1.0.0
