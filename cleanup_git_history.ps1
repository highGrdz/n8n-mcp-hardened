# ============================================================
# DOE Framework - Script de Limpeza de Histórico Git
# Remove data/nodes.db de todo o histórico e faz force push
# ⚠️  Execute dentro da pasta: .tmp\n8n-mcp-staging
# ============================================================

Write-Host "🔍 [1/5] Verificando dependência: git-filter-repo..." -ForegroundColor Cyan
$filterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue
if (-not $filterRepo) {
    Write-Host "📦 Instalando git-filter-repo via pip..." -ForegroundColor Yellow
    pip install git-filter-repo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Falha ao instalar git-filter-repo. Instale Python e tente novamente." -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ git-filter-repo disponível." -ForegroundColor Green

# -------------------------------------------------------
Write-Host ""
Write-Host "📝 [2/5] Atualizando .gitignore (nodes.db excluído)..." -ForegroundColor Cyan
git add .gitignore
git commit -m "chore: exclude data/nodes.db from tracking (arquivo binario grande)"
Write-Host "✅ .gitignore commitado." -ForegroundColor Green

# -------------------------------------------------------
Write-Host ""
Write-Host "🧹 [3/5] Removendo data/nodes.db de todo o histórico git..." -ForegroundColor Cyan
Write-Host "⚠️  Isso reescreve o histórico — é irreversível sem backup." -ForegroundColor Yellow

git filter-repo --path data/nodes.db --invert-paths --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ git filter-repo falhou. Verifique se está na pasta correta." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Histórico limpo. nodes.db removido de todos os commits." -ForegroundColor Green

# -------------------------------------------------------
Write-Host ""
Write-Host "🔗 [4/5] Reconfigurando remote (filter-repo remove remotes por segurança)..." -ForegroundColor Cyan
git remote add meu-repo https://github.com/highGrdz/n8n_mcp_hardened.git
Write-Host "✅ Remote 'meu-repo' restaurado." -ForegroundColor Green

# -------------------------------------------------------
Write-Host ""
Write-Host "🚀 [5/5] Fazendo force push para meu-repo/main..." -ForegroundColor Cyan
Write-Host "⚠️  Force push em andamento — não interrompa!" -ForegroundColor Yellow

git push meu-repo main --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Force push falhou. Verifique suas credenciais e tente manualmente:" -ForegroundColor Red
    Write-Host "   git push meu-repo main --force" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "🎉 Concluído! Repositório limpo e atualizado." -ForegroundColor Green
Write-Host "   ✅ data/nodes.db removido do histórico" -ForegroundColor Green
Write-Host "   ✅ .gitignore atualizado (não voltará a ser commitado)" -ForegroundColor Green
Write-Host "   ✅ Force push realizado" -ForegroundColor Green
