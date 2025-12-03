# 📋 Pipeline CI/CD - Backlog de Tarefas (Jira)

## ✅ Já Implementado

- [x] **CI-001**: Análise estática de código (`flutter analyze`)
- [x] **CI-002**: Testes unitários e de widget (`flutter test`)
- [x] **CI-003**: Verificação de formatação (`dart format`)
- [x] **CI-004**: Relatório de cobertura de testes

---

## 🚀 Tarefas Pendentes - Sprint Futuro

### 📱 Build e Deploy Android

#### **TASK-001: Build APK de Debug Automático**
**Descrição:** Criar workflow para gerar APK de debug automaticamente em cada push  
**Prioridade:** Alta  
**Estimativa:** 3 Story Points  
**Critérios de Aceitação:**
- APK gerado automaticamente no CI
- APK disponível como artefato para download
- Build executado apenas em branches específicas (develop, main)

**Subtarefas:**
- [ ] Criar workflow `.github/workflows/build_android_debug.yml`
- [ ] Configurar cache do Gradle
- [ ] Adicionar step de upload do APK como artefato
- [ ] Testar workflow em branch de teste

---

#### **TASK-002: Build AAB para Release (Google Play)**
**Descrição:** Criar workflow para gerar AAB assinado para publicação na Play Store  
**Prioridade:** Alta  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- AAB assinado gerado automaticamente
- Secrets configurados no GitHub (keystore, senha)
- Build executado apenas em tags de release

**Subtarefas:**
- [ ] Criar workflow `.github/workflows/build_android_release.yml`
- [ ] Configurar signing do Android (keystore)
- [ ] Adicionar secrets no GitHub: `ANDROID_KEYSTORE_BASE64`, `KEY_PASSWORD`, `STORE_PASSWORD`
- [ ] Gerar e versionar corretamente o AAB
- [ ] Upload do AAB como artefato

**Documentação Necessária:**
- Comando para gerar keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- Configurar `android/key.properties` (NÃO commitar)

---

#### **TASK-003: Deploy Automático para Google Play (Beta/Produção)**
**Descrição:** Implementar deploy automático para Google Play Console  
**Prioridade:** Média  
**Estimativa:** 8 Story Points  
**Critérios de Aceitação:**
- Upload automático para track de Beta na Play Store
- Upload para Produção apenas com aprovação manual
- Integração com Google Play Developer API

**Subtarefas:**
- [ ] Criar Service Account no Google Cloud Console
- [ ] Configurar permissões no Play Console
- [ ] Adicionar secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- [ ] Criar workflow `.github/workflows/deploy_android_playstore.yml`
- [ ] Implementar lógica de versionamento automático (versionCode e versionName)
- [ ] Testar deploy em track de teste interno

---

### 🍎 Build e Deploy iOS

#### **TASK-004: Build iOS Simulator**
**Descrição:** Configurar build para iOS Simulator (desenvolvimento)  
**Prioridade:** Média  
**Estimativa:** 3 Story Points  
**Critérios de Aceitação:**
- Build iOS para simulator executado no CI
- Artefato .app disponível para download

**Subtarefas:**
- [ ] Configurar runner macOS no GitHub Actions (`runs-on: macos-latest`)
- [ ] Criar workflow `.github/workflows/build_ios_simulator.yml`
- [ ] Configurar Xcode e certificados
- [ ] Testar build

---

#### **TASK-005: Build iOS Release (IPA para TestFlight)**
**Descrição:** Criar workflow para gerar IPA assinado para TestFlight  
**Prioridade:** Média  
**Estimativa:** 13 Story Points (Complexo)  
**Critérios de Aceitação:**
- IPA assinado gerado automaticamente
- Certificados e Provisioning Profiles configurados
- Build executado apenas em tags de release

**Subtarefas:**
- [ ] Criar workflow `.github/workflows/build_ios_release.yml`
- [ ] Configurar certificados da Apple (Distribution Certificate)
- [ ] Configurar Provisioning Profile
- [ ] Adicionar secrets: `IOS_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`
- [ ] Configurar Fastlane (recomendado)
- [ ] Gerar IPA assinado
- [ ] Upload como artefato

**Documentação Necessária:**
- Configurar Apple Developer Account
- Gerar certificados via Xcode ou Apple Developer Portal
- Converter certificado para base64: `base64 -i certificate.p12 | pbcopy`

---

#### **TASK-006: Deploy Automático para TestFlight/App Store**
**Descrição:** Implementar deploy automático para TestFlight e App Store  
**Prioridade:** Baixa  
**Estimativa:** 13 Story Points (Complexo)  
**Critérios de Aceitação:**
- Upload automático para TestFlight
- Upload para App Store apenas com aprovação manual
- Integração com App Store Connect API

**Subtarefas:**
- [ ] Configurar App Store Connect API Key
- [ ] Adicionar secret `APP_STORE_CONNECT_API_KEY`
- [ ] Criar workflow `.github/workflows/deploy_ios_appstore.yml`
- [ ] Implementar Fastlane para upload
- [ ] Configurar versionamento automático
- [ ] Testar upload para TestFlight

---

### 🔧 Melhorias de Code Quality

#### **TASK-007: Integração com SonarQube/SonarCloud**
**Descrição:** Adicionar análise de qualidade de código com SonarQube  
**Prioridade:** Baixa  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- Integração com SonarCloud configurada
- Métricas de qualidade visíveis no PR
- Badge de qualidade no README

**Subtarefas:**
- [ ] Criar conta no SonarCloud
- [ ] Configurar projeto no SonarCloud
- [ ] Adicionar step de análise no workflow CI
- [ ] Configurar `sonar-project.properties`
- [ ] Adicionar badge no README

---

#### **TASK-008: Análise de Dependências (Dependabot)**
**Descrição:** Configurar Dependabot para atualização automática de dependências  
**Prioridade:** Média  
**Estimativa:** 2 Story Points  
**Critérios de Aceitação:**
- Dependabot configurado para pubspec.yaml
- PRs automáticos para atualizações de dependências
- Verificação automática de segurança

**Subtarefas:**
- [ ] Criar `.github/dependabot.yml`
- [ ] Configurar schedule de verificação (semanal)
- [ ] Configurar assignees e labels
- [ ] Testar com uma dependência desatualizada

---

#### **TASK-009: Verificação de Segurança (OWASP)**
**Descrição:** Adicionar análise de segurança com ferramentas OWASP  
**Prioridade:** Baixa  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- Scan de segurança executado no CI
- Vulnerabilidades críticas bloqueiam o build
- Relatório de segurança gerado

**Subtarefas:**
- [ ] Pesquisar ferramentas OWASP para Flutter/Dart
- [ ] Integrar ferramenta no workflow
- [ ] Configurar thresholds de severidade
- [ ] Documentar processo de correção de vulnerabilidades

---

### 📊 Monitoramento e Notificações

#### **TASK-010: Notificações no Slack/Discord**
**Descrição:** Enviar notificações de build para canal do Slack/Discord  
**Prioridade:** Baixa  
**Estimativa:** 3 Story Points  
**Critérios de Aceitação:**
- Notificação enviada em caso de falha no build
- Notificação enviada em caso de sucesso em produção
- Mensagem com link para o workflow

**Subtarefas:**
- [ ] Criar Webhook do Slack/Discord
- [ ] Adicionar secret `SLACK_WEBHOOK_URL`
- [ ] Adicionar step de notificação nos workflows
- [ ] Customizar mensagens por tipo de evento

---

#### **TASK-011: Dashboard de Métricas (Badges no README)**
**Descrição:** Adicionar badges de status no README.md  
**Prioridade:** Baixa  
**Estimativa:** 1 Story Point  
**Critérios de Aceitação:**
- Badge de status do CI
- Badge de cobertura de testes
- Badge de versão do app

**Subtarefas:**
- [ ] Adicionar badge do GitHub Actions
- [ ] Adicionar badge do Codecov
- [ ] Adicionar badge de versão (shields.io)
- [ ] Organizar seção de badges no README

---

### 🗄️ Database e Backend

#### **TASK-012: Validação de Migrations SQL**
**Descrição:** Criar pipeline para validar scripts SQL antes do merge  
**Prioridade:** Média  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- Scripts SQL validados automaticamente
- Testes de sintaxe executados
- Preview das mudanças gerado

**Subtarefas:**
- [ ] Criar workflow `.github/workflows/validate_sql.yml`
- [ ] Configurar PostgreSQL em container para testes
- [ ] Adicionar linter SQL (sqlfluff ou similar)
- [ ] Testar migrations em banco temporário

---

#### **TASK-013: CI/CD Backend Node.js (se aplicável)**
**Descrição:** Criar pipeline para o backend Node.js  
**Prioridade:** Alta (se houver backend separado)  
**Estimativa:** 8 Story Points  
**Critérios de Aceitação:**
- Testes do backend executados
- Linting (ESLint) configurado
- Deploy automático para servidor

**Subtarefas:**
- [ ] Criar workflow `.github/workflows/backend_ci.yml`
- [ ] Configurar Node.js
- [ ] Executar testes (`npm test`)
- [ ] Executar linter (`npm run lint`)
- [ ] Configurar deploy (Heroku, AWS, Digital Ocean, etc)

---

### 📱 Distribuição e Beta Testing

#### **TASK-014: Firebase App Distribution**
**Descrição:** Configurar distribuição de builds beta via Firebase  
**Prioridade:** Média  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- Builds de debug distribuídos automaticamente
- Testers recebem notificação de nova versão
- Release notes automáticas

**Subtarefas:**
- [ ] Configurar Firebase App Distribution
- [ ] Criar workflow para distribuição
- [ ] Configurar grupos de testers
- [ ] Automatizar release notes (commit messages)

---

#### **TASK-015: Versionamento Semântico Automático**
**Descrição:** Implementar versionamento automático baseado em Conventional Commits  
**Prioridade:** Baixa  
**Estimativa:** 5 Story Points  
**Critérios de Aceitação:**
- Version bump automático (patch, minor, major)
- Tags git criadas automaticamente
- Changelog gerado automaticamente

**Subtarefas:**
- [ ] Pesquisar ferramenta (semantic-release, standard-version)
- [ ] Configurar conventional commits
- [ ] Criar workflow para release
- [ ] Atualizar pubspec.yaml automaticamente
- [ ] Gerar CHANGELOG.md

---

## 📈 Métricas de Sucesso

**KPIs para avaliar o Pipeline:**
- ✅ **Tempo de build:** < 15 minutos para CI completo
- ✅ **Cobertura de testes:** > 70% (ideal: > 85%)
- ✅ **Taxa de sucesso:** > 95% dos builds sem falhas
- ✅ **Tempo de deploy:** < 30 minutos para produção
- ✅ **Frequência de deploy:** Pelo menos 1x por semana

---

## 🗂️ Organização no Jira

### **Epic:** Pipeline CI/CD TrabalheJá
**Sprints Sugeridos:**

**Sprint 1 (Atual) - Concluído ✅:**
- CI-001, CI-002, CI-003, CI-004

**Sprint 2 - Builds Android:**
- TASK-001, TASK-002

**Sprint 3 - Deploy Android:**
- TASK-003, TASK-014

**Sprint 4 - Builds iOS:**
- TASK-004, TASK-005

**Sprint 5 - Deploy iOS:**
- TASK-006

**Sprint 6 - Melhorias:**
- TASK-007, TASK-008, TASK-009

**Sprint 7 - Extras:**
- TASK-010, TASK-011, TASK-012, TASK-013, TASK-015

---

## 📚 Recursos e Documentação

**Links Úteis:**
- [GitHub Actions - Flutter CI/CD](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-flutter)
- [Fastlane para Flutter](https://docs.fastlane.tools/getting-started/flutter/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Codemagic Documentation](https://docs.codemagic.io/flutter-continuous-integration/)
- [Play Store Publishing](https://developer.android.com/studio/publish)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)

---

**Criado em:** {{ date }}  
**Última atualização:** {{ date }}  
**Responsável:** Time de DevOps/Infra

