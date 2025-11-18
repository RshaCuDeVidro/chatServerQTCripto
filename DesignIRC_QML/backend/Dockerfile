# ---- Estágio 1: Builder ----
# Instala dependências de build e compila os pacotes
FROM python:3.12-slim AS builder

WORKDIR /app

# Instala dependências do sistema (necessárias para compilar)
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala dependências Python

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ---- Estágio 2: Final ----
# A imagem final, que será muito menor
FROM python:3.12-slim

WORKDIR /app

# Instala APENAS as dependências de RUNTIME
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia o ambiente virtual com os pacotes já instalados do estágio 'builder'
COPY --from=builder /opt/venv /opt/venv

# Copia o código da aplicação
COPY . .

# Expõe a porta
EXPOSE 8765

# Ativa o venv e executa o comando
ENV PATH="/opt/venv/bin:$PATH"
CMD ["python", "main.py"]
