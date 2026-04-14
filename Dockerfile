# ==========================================
# STAGE 1: Builder (Cache e Compilação)
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /app

# Otimização de Cache: Copia apenas arquivos de dependência primeiro
COPY package.json package-lock.json ./

# Instala dependências com lockfile estrito
RUN npm install -g npm@latest && npm ci

# Copia o resto do código
COPY . .

# Compila o TypeScript
RUN npm run build

# Remove pacotes de desenvolvimento para economizar espaço
RUN npm prune --production

# ==========================================
# STAGE 2: Distroless (Runtime Zero-Trust)
# ==========================================
FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app

# Copia apenas os artefatos finais do builder
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Diretriz de privilégio mínimo
USER nonroot

# Entrypoint via node diretamente
CMD ["build/index.js"]
