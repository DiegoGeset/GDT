# 🚀 **GDT - Geset Diagnostic Tool**

![Windows](https://img.shields.io/badge/Plataforma-Windows-blue) ![PowerShell](https://img.shields.io/badge/Linguagem-PowerShell-purple) ![Automação](https://img.shields.io/badge/Automação-Scripts-green)

Bem-vindo a ferramenta **GDT - Geset Diagnostic Tool**! Uma coleção de **scripts PowerShell**,
Baseados em automatizar processos de configuração pós formatação e de otimização do **windows 10/11**.

---

## ⚠️ Avisos de Segurança

* Execute scripts **com permissões administrativas**
* Caso o Script seja executado sem permissão elevada, ele mesmo tentara executar novamente com permissões elevadas
* Revise scripts que alteram **sistema, rede ou contas de usuário**
* Faça **backup de dados importantes** antes de executar scripts de limpeza ou otimização

---

## ⚡ Como Usar

1. **Abra o powershell (De preferencia em administrador)**

2. **Inicie o AutoTool**

```powershell
irm "https://raw.githubusercontent.com/DiegoGeset/Tool/main/Launcher.ps1" | iex
```

3. **Selecione a categoria e script desejado**
4. **Leia os arquivos `.txt`** para entender cada script antes de executar

---

## 📂 Estrutura do Repositório

```
Categoria/
   ├── Subpasta Script/
       ├── Script.ps1  (Script executável)
       └── Script.txt  (Descrição e instruções)
```

* **Categorias:** Contas de Usuário, Correção, Formatação, Limpeza, Otimização, Rede
* **Subpastas:** Cada script individual organizado por funcionalidade

---

## 🛠️ Categorias e Scripts

### 1️⃣ **Contas de Usuário**

| Script                       | Descrição                                                           |
| ---------------------------- | ------------------------------------------------------------------- |
| `Administrador.ps1`          | 🔑 **Altera a senha do usuário Administrador**                      |
| `Controle Conta Usuario.ps1` | 🛡️ **Habilita ou desabilita os usuarios do computador(UAC)** |

---

### 2️⃣ **Correção**

| Script       | Descrição                                     |
| ------------ | --------------------------------------------- |
| `CHKDSK.ps1` | 💽 **Verifica e corrige erros no disco**      |
| `Sfc.ps1`    | 🧩 **Repara arquivos de sistema corrompidos** |

---

### 3️⃣ **Formatação**

| Script            | Descrição                                                              |
| ----------------- | ---------------------------------------------------------------------- |
| `PosFormatar.ps1` | ⚡ **Automatiza instalação de softwares e configuração pós-formatação** |

---

### 4️⃣ **Limpeza**

| Script                      | Descrição                                     |
| --------------------------- | --------------------------------------------- |
| `Remove microsoft apps.ps1` | 🧹 **Remove aplicativos nativos do Windows**  |
| `Programas.ps1`             | ❌ **Remove o OneDrive**                       |
| `Limpeza.ps1`               | 🗑️ **Limpa arquivos temporários do sistema** |
| `LimpezaChrome.exe`         | 🚀 **Limpa cache do Google Chrome**           |
| `LimpezaEdge.exe`           | 🚀 **Limpa cache do Microsoft Edge**          |
| `LimpezaLixeira.exe`        | ♻️ **Esvazia a Lixeira**                      |
| `LimpezaPrefetch.exe`       | 🏎️ **Limpa pré-buscas do Windows**           |
| `Impressoras.ps1`           | 🖨️ **Remove impressoras antigas**            |

---

### 5️⃣ **Otimização**

| Script                  | Descrição                                              |
| ----------------------- | ------------------------------------------------------ |
| `Plano de energia.ps1`  | ⚡ **Ajusta o plano de energia para máximo desempenho** |
| `Atualizar Windows.ps1` | 🔄 **Atualiza o Windows para a versão mais recente**   |
| `Classic.ps1`           | 🖱️ **Restaura o menu de propriedadas clássico**           |
| `Icone.ps1`             | 🖼️ **Organiza ícones na área de trabalho**            |
| `Inicializar.ps1`       | 🔧 **Configura scripts para iniciar com o Windows**    |
| `Desempenho.ps1`        | 🚀 **Ajusta configurações de desempenho do sistema**   |
| `Sys Info.ps1`          | 📊 **Gera informações detalhadas do sistema**          |

---

### 6️⃣ **Rede**

| Script          | Descrição                                             |
| --------------- | ----------------------------------------------------- |
| `Flush DNS.ps1` | 🌐 **Limpa cache DNS do Windows**                     |
| `Ipv6.ps1`      | ❌ **Desabilita protocolo IPv6 de todos os adaptadores de rede** |

---

## 🎮 Ideia de toda a Interface

O **Launcher** é o coração do **AutoTool**:

* 💡 **Interface organizada** por categorias
* 🔹 **Seleção de scripts individuais**
* 📝 **Exibe descrições detalhadas antes da execução**
* ⚡ **Automatiza processos complexos** (limpeza, otimização, manutenção)

> Objetivo: tornar a execução dos scripts simples, segura e acessível em qualquer terminal Windows 10/11.

---
