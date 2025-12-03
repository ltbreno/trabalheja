#!/bin/bash

# Script para executar todas as verificações do CI localmente
# Uso: ./scripts/ci_check.sh

set -e  # Parar em caso de erro

echo "🚀 =================================="
echo "   TrabalheJá - Verificação Local CI"
echo "🚀 =================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir sucesso
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Função para imprimir erro
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para imprimir info
print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 1. Verificar se Flutter está instalado
echo "🔍 Verificando instalação do Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter não encontrado. Por favor, instale o Flutter primeiro."
    exit 1
fi
print_success "Flutter encontrado: $(flutter --version | head -n 1)"
echo ""

# 2. Limpar cache (opcional)
read -p "🧹 Limpar cache do Flutter? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Limpando cache..."
    flutter clean
    print_success "Cache limpo!"
    echo ""
fi

# 3. Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependências instaladas!"
else
    print_error "Falha ao instalar dependências"
    exit 1
fi
echo ""

# 4. Verificar formatação
echo "🔍 Verificando formatação do código..."
echo "   Executando: dart format --set-exit-if-changed --line-length 100 lib/ test/"
if dart format --set-exit-if-changed --line-length 100 lib/ test/; then
    print_success "Formatação OK!"
else
    print_error "Código não está formatado corretamente"
    echo ""
    print_info "Para corrigir automaticamente, execute:"
    echo "   dart format --line-length 100 lib/ test/"
    exit 1
fi
echo ""

# 5. Análise estática
echo "🔎 Executando análise estática..."
echo "   Executando: flutter analyze --fatal-infos --fatal-warnings"
if flutter analyze --fatal-infos --fatal-warnings; then
    print_success "Análise estática passou!"
else
    print_error "Problemas encontrados na análise estática"
    echo ""
    print_info "Corrija os problemas acima antes de fazer commit"
    exit 1
fi
echo ""

# 6. Executar testes
echo "🧪 Executando testes..."
echo "   Executando: flutter test --coverage --reporter expanded"
if flutter test --coverage --reporter expanded; then
    print_success "Todos os testes passaram!"
else
    print_error "Alguns testes falharam"
    echo ""
    print_info "Corrija os testes antes de fazer commit"
    exit 1
fi
echo ""

# 7. Verificar cobertura (se lcov estiver instalado)
if command -v lcov &> /dev/null; then
    echo "📊 Gerando relatório de cobertura..."
    if [ -f "coverage/lcov.info" ]; then
        lcov --summary coverage/lcov.info 2>&1 | grep -A 3 "Summary coverage" || true
        print_success "Relatório de cobertura gerado!"
        echo ""
        print_info "Para visualizar o relatório HTML:"
        echo "   genhtml coverage/lcov.info -o coverage/html"
        echo "   open coverage/html/index.html"
    else
        print_info "Arquivo de cobertura não encontrado"
    fi
else
    print_info "lcov não instalado. Pulando relatório de cobertura."
    echo "   Para instalar:"
    echo "   - Ubuntu/Debian: sudo apt-get install lcov"
    echo "   - macOS: brew install lcov"
fi
echo ""

# 8. Resumo final
echo "🎉 =================================="
echo "   ✅ TODAS AS VERIFICAÇÕES PASSARAM!"
echo "🎉 =================================="
echo ""
echo "Você está pronto para fazer commit e push! 🚀"
echo ""
echo "Próximos passos:"
echo "  1. git add ."
echo "  2. git commit -m 'feat: sua mensagem'"
echo "  3. git push"
echo ""

