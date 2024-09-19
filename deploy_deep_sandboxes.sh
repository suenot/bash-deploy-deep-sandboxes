#!/bin/bash

# Список песочниц
sandboxes=("bull-market-arena" "bearish-breakout" "pivot-point-plaza")
email="suenot@gmail.com"
main_domain="marketmaker.cc"

# Путь к рабочей директории с уникальной меткой времени
timestamp=$(date +%s)
base_dir="/mnt/first/work/provision-$timestamp"

# Создаем папку для запуска с меткой времени
mkdir -p $base_dir
cd $base_dir

# Клонируем репозиторий с letsencrypt
if [ ! -d "$base_dir/nginx-letsencrypt" ]; then
  git clone https://github.com/suenot/nginx-letsencrypt
  cd nginx-letsencrypt
  npm i commander
  cd ..
else
  echo "nginx-letsencrypt уже клонирован."
fi

# Генерация сертификатов для каждой песочницы
for sandbox in "${sandboxes[@]}"; do
  echo "Создание сертификатов для песочницы: $sandbox"

  cd nginx-letsencrypt
  perception_domain="perception.$sandbox.$main_domain"
  deeplinks_domain="deeplinks.$sandbox.$main_domain"
  
  node index.js --configurations "$perception_domain 3007" "$deeplinks_domain 3006" --certbot-email $email --file-name $sandbox

  echo "Сертификаты для $sandbox созданы."
  cd ..
done

# Устанавливаем deep.foundation проект через docker-compose для каждой песочницы
for sandbox in "${sandboxes[@]}"; do
  echo "Разворачивание песочницы: $sandbox"

  # Создаем папку для песочницы
  mkdir -p "$base_dir/$sandbox"
  cd "$base_dir/$sandbox"
  
  # Выполняем команды npx для развертывания проекта
  npx -y @deep-foundation/deeplinks --generate --ssl --deeplinks="https://deeplinks.$sandbox.$main_domain" --perception="https://perception.$sandbox.$main_domain"
  npx -y @deep-foundation/deeplinks --up
  npx -y @deep-foundation/deeplinks --snapshot
  
  echo "Разворачивание песочницы $sandbox завершено."
  cd ..
done

