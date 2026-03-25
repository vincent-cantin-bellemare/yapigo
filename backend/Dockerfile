FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# --- System dependencies: git + Docker CLI ---
RUN apt-get update && apt-get install -y \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
        https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# --- PostgreSQL client (psql, pg_dump, pg_isready) + psycopg build deps ---
RUN apt-get update && apt-get install --auto-remove -y \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# --- rclone (Google Drive backups) ---
RUN apt-get update && apt-get install --auto-remove -y unzip \
    && curl https://rclone.org/install.sh | bash \
    && rm -rf /var/lib/apt/lists/*

# --- Python dependencies (copied before code for Docker cache optimization) ---
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -r /app/requirements/base.txt

# --- Application code ---
COPY ./code /app/code

WORKDIR /app/code

# --- Bash aliases for Dev Container terminal ---
RUN echo '\n\
# RunDate management command aliases\n\
alias runserver="cd /app/code && python3 manage.py runserver 0.0.0.0:8000"\n\
alias runserver_graphql="cd /app/code && DJANGO_SETTINGS_MODULE=config.settings_graphql python3 manage.py runserver 0.0.0.0:8001"\n\
alias migrate="cd /app/code && python3 manage.py migrate"\n\
alias makemigrations="cd /app/code && python3 manage.py makemigrations"\n\
alias shell="cd /app/code && python3 manage.py shell"\n\
alias dbshell="cd /app/code && python3 manage.py dbshell"\n\
alias test="cd /app/code && python3 manage.py test"\n\
alias collectstatic="cd /app/code && python3 manage.py collectstatic --noinput"\n\
alias showmigrations="cd /app/code && python3 manage.py showmigrations"\n\
alias createsuperuser="cd /app/code && python3 manage.py createsuperuser"\n\
alias flush="cd /app/code && python3 manage.py flush"\n\
alias flake="cd /app/code && flake8"\n\
alias seed="cd /app/code && python3 manage.py seed_all"\n\
' >> /root/.bashrc

EXPOSE 8000 8001
