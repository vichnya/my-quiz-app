# Используйте базовый образ Nginx
FROM nginx:latest

# Копируйте статические файлы в директорию nginx/html на вашем сервере
COPY quiz /usr/share/nginx/html 

# Этот шаг необходим для Nginx, чтобы правильно обслуживать статические файлы
RUN chmod -R 755 /usr/share/nginx/html

# Этот шаг нужен для использования ваших html вместо стандартной страницы nginx (путь к nginx.conf на вашем сервере)
ENTRYPOINT nginx -c /etc/nginx/nginx.conf -g 'daemon off;'

# Опционально: прокиньте порты, если это необходимо
EXPOSE 80
