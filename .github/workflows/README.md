# 🚀 GitHub Actions - CI/CD Pipeline

Este diretório contém os workflows de CI/CD do projeto TrabalheJá.

---

## 📋 Workflows Disponíveis

### 1. **Flutter CI** (`flutter_ci.yml`)
**Trigger:** Push ou PR nas branches `main` e `develop`  
**Duração:** ~5-10 minutos  
**O que faz:**
- ✅ Verifica formatação do código (`dart format`)
- ✅ Executa análise estática (`flutter analyze`)
- ✅ Roda testes unitários e de widget (`flutter test`)
- ✅ Gera relatório de cobertura de testes
- ✅ Upload do relatório para Codecov (opcional)

---

## 🔧 Como Usar

### Executar o CI localmente antes de fazer push

```bash
# 1. Verificar formatação
dart format --set-exit-if-changed --line-length 100 lib/ test/

# 2. Análise estática
flutter analyze --fatal-infos --fatal-warnings

# 3. Executar testes
flutter test --coverage
```

### Corrigir problemas de formatação

```bash
# Formatar automaticamente
dart format --line-length 100 lib/ test/
```

### Visualizar cobertura de testes localmente

```bash
# Gerar cobertura
flutter test --coverage

# Instalar lcov (Linux/Mac)
# Ubuntu: sudo apt-get install lcov
# Mac: brew install lcov

# Gerar HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html  # Mac
xdg-open coverage/html/index.html  # Linux
```

---

## 🎯 Status dos Workflows

Você pode ver o status dos workflows:
- Na aba **Actions** do repositório no GitHub
- No badge do README (quando adicionado)
- Nas Pull Requests (checks automáticos)

---

## 🔐 Secrets Configurados

Atualmente não há secrets configurados. Quando adicionarmos deploy, será necessário:

### Para Android:
- `ANDROID_KEYSTORE_BASE64` - Keystore em base64
- `KEY_PASSWORD` - Senha da key
- `STORE_PASSWORD` - Senha do keystore

### Para iOS:
- `IOS_CERTIFICATE_BASE64` - Certificado em base64
- `IOS_CERTIFICATE_PASSWORD` - Senha do certificado
- `IOS_PROVISIONING_PROFILE_BASE64` - Provisioning profile em base64

### Para Deploy:
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Service account da Play Store
- `APP_STORE_CONNECT_API_KEY` - API key da App Store

---

## 🐛 Troubleshooting

### Workflow falhou na verificação de formatação
```bash
# Execute localmente para ver os arquivos não formatados
dart format --set-exit-if-changed lib/ test/

# Corrija formatando
dart format lib/ test/

# Commit e push
git add .
git commit -m "style: fix code formatting"
git push
```

### Workflow falhou na análise estática
```bash
# Execute localmente para ver os erros
flutter analyze

# Corrija os erros indicados
# Commit e push
git add .
git commit -m "fix: resolve linter issues"
git push
```

### Testes falharam
```bash
# Execute localmente para ver qual teste falhou
flutter test --reporter expanded

# Corrija o teste ou o código
# Commit e push
git add .
git commit -m "fix: resolve failing tests"
git push
```

---

## 📚 Documentação Adicional

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Dart Format](https://dart.dev/tools/dart-format)
- [Flutter Analyze](https://flutter.dev/docs/testing/debugging#the-dart-analyzer)
- [Flutter Test](https://flutter.dev/docs/testing)

---

## 🔄 Próximos Passos

Consulte o arquivo `PIPELINE_TODO_JIRA.md` na raiz do projeto para ver as próximas implementações planejadas:
- Build automático de APK/AAB
- Build automático de IPA
- Deploy para Play Store
- Deploy para App Store
- Integração com SonarQube
- E muito mais!

