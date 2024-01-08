# Задание 3.2. Спроектировать решение в виде набора для запуска с использованием Docker для работы автоматизации развертывания викторин, аналогичных тому, что расположены по адресу apps.pr-cbs.ru.

Авторы:
* Чернышева Виктория
* Иванова Мария
* Буряков Иван
---
  > ## Данный проект позволяет при Commit:
  > * отправлять обновления в DockerHub;
  > * отправлять обновления на удаленный сервер;
  > * перезапускать Docker контейнер на удаленном сервере, что приводит к изменению страниц сервера.
  
## Туториал по запуску проекта
#### 1. Скачивание репозитория на локальный компьютер и развертывание Docker локально

Для дальнейших действий на вашем компьютере должен быть установлен Docker:
* [ Установка Docker в Windows](https://devhops.ru/dvps/docker/install/windows/)
* [ WSL для Docker в Windows](https://learn.microsoft.com/en-us/windows/wsl/install)

Скачайте репозиторий с GitHub. Разархивируйте проект.   
В командной строке перейдите в директорию с проектом. Соберите проект и локально запустите проект.
```
docker build -t {name_image}:latest . 
# name_image - название создаваемого образа

docker run -p 80:80 --name {name_ps}  {name_image}:latest 
# -p - порт на котором будет запущен создаваемый контейнер;
# --name - название создаваемого контейнера.
```
В нашем случае
```
docker build -t my-nginx:latest . 
docker run -p 80:80 --name glav my-nginx:latest 
```
#### 2.  Создание репозитория [Docker Hub](https://hub.docker.com/)

Нужно создать репозиторий на [Docker Hub](https://hub.docker.com/). Для этого зарегистрируйтесь на сервисе или, при наличии аккаунта, - авторизируйтесь. В вкладке репозиторий создайте новый репозиторий. В дальнейшем нам понадобится логин, пароль и название созданного репозитория.

#### 3. Отправка файлов в Docker Hub

Чтобы отправить наш образ в Docker Hub нужно воспользоваться командой push.
```
docker login
# Авторизация в DockerHub

docker tag {name_image}:latest {DockerHub_login}/{DockerHub_Repo}:latest
# создаем тэг, где
# {name_image}:latest - созданный локально образ
# {DockerHub_login}/{DockerHub_Repo}:latest - логин в DockerHub/название репозитория в DockerHub

docker push {DockerHub_login}/{DockerHub_Repo}:latest
# Отпавка образа в DockerHub
```
В нашем случае
```
docker login
docker tag my-nginx:latest vishnya1chern/my-nginx:latest
docker push vishnya1chern/my-nginx:latest
```

#### 4.  Запуск удаленного сервера

Удобным вам образом подключаемся к удаленному серверу. 
Конфигурация сервера, в котором идет дальнейшая работа - Ubuntu22.04x86_64
```
# Windows PowerShell
ssh root@host  #host - IP вашего сервера
```
#### 5. Установка docker на удаленном сервере
```
# Обновите пакеты
sudo apt update

# Установите пакеты, которые необходимы для работы пакетного менеджера apt по протоколу [HTTPS](https://www.reg.ru/ssl-certificate/)
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Добавьте GPG-ключ репозитория Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Добавьте репозиторий Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# Обновите пакеты
sudo apt update

# Переключитесь в репозиторий Docker, чтобы его установить
apt-cache  policy docker-ce

# Установите Docker
sudo apt install docker-ce

# Проверьте работоспособность программы (в терминале должна появиться информация о том, что Docker активен)
sudo systemctl status docker
```
#### 6.  Запуск проекта на удаленном сервере
Чтобы загрузить образ из DockerHub нужно воспользоваться командой pull.
```
docker login
# Авторизация в DockerHub

docker pull {DockerHub_login}/{DockerHub_Repo}:latest
# Загрузка образа из DockerHub

docker run  -p 80:80 --name {name_ps} -d {DockerHub_login}/{DockerHub_Repo}
```
В нашем случае
```
docker login
docker pull vishnya1chern/my-nginx
docker run  -p 80:80 --name glav -d vishnya1chern/my-nginx
```
Также, если на вашем сервере запущен nginx, выключите его, чтобы не было конфликтов
```
sudo systemctl stop nginx
```
> ## На данный момент имеем:
> * Сборку приложения в докере
> * Репозиторий на Dockerhub
> * Работающий контейнер на сервере

## Туториал по автоматизации проекта с помощью GitHub Actions
#### 1. Работа с SSH ключами на удаленном сервере
Создаем пару ключей (публичный и приватный) на удаленном сервере. 
В нашем случае ключи создавались без пароля.
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
После создания переходим в директорию с ключами (путь к ней будет отображен при создании ключей).

В директории появятся два ключа - id_rsa и id_rsa.pub, соответствующие приватному и публичному ключу. Помимо них в директории будет и должен находиться файл authorized_keys.

Публичный ключ (id_rsa.pub) нужно скопировать и втавить в файл authorized_keys.
Ленивый способ
```
cat id_rsa.pub
# Будет отображено содержимое id_rsa.pub
# ctrl + c

nano authorized_keys
# ctrl + v
# ctrl + x (для выхода из nano)
# y (для сохранения изменений)
# Enter (для возвращения в cmd)
```

Приватный ключ (id_rsa) необходимо записать локально в блокнот или другой текстовый редактор, или непосредственно вставаить в секретные ключи GitHub (подробнее см. след. раздел) 

#### 2. Создание директории build в корневом каталоге
На удаленном сервере перейдите в корневой каталог и создайте директорию build. В дальнейшем туда будет отправляться последняя версия проекта.
```
mkdir build
```

#### 3. Создание репозитория в GitHub и настройка проекта в GitHub
Для дальнейшей работы необходим аккаунт в [GitHub](https://github.com/). Создайте новый репозиторий в GitHub. Загрузите в него проект. Загрузке подвергнуться все файлы, кроме директории .github и содержащихся в ней файлов.

Создайте секретные ключи в разделе Settings -> Secrets and variables ->Actions репозитория:
* DOCKER_USERNAME : логин от DockerHub
* DOCKER_PASSWORD : пароль от DockerHub
* DOCKER_REPO_NAME: название репозитория в DockerHub
* SERVER_HOST : IP удаленного сервера (можно в виде 0.0.0.0)
* SSH_KEY : Приватный ключ, созданный на предыдущем пункте
* USERNAME : root 
* PASSWORD : Пароль для подключения к удаленному серверу

Как должна выглядеть страница после добавления ключей
![foto1](https://github.com/vichnya/Dec_praktika_2023/blob/main/3.2/foto1.png)

Перейдите во вкладку Actions. Там вам будет предложено создать стартовый simpe workflow.
![foto2](https://github.com/vichnya/Dec_praktika_2023/blob/main/3.2/foto2.png)

Создаем стартовый simpe workflow. Переносим код из 
my-quiz-app/.github/workflows/deploy.yml в ваш simpe workflow.

Код из my-quiz-app/.github/workflows/deploy.yml:
```
name: Publish to server

on:
  push:
    branches: [ "main" ]

jobs:

  push_to_registry:
    name: Publish to server
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v3
      
      - name: Log in to Docker Hub
        uses: docker/login-action@f054a8b539a109f9f41c372932f1ae047eff08c9
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@98669ae865ea3cffbcbaa878cf57c20bbf1c6c38
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/${{ secrets.DOCKER_REPO_NAME }}
          tags: latest
          labels: latest
          
      - name: Build and push Docker image
        uses: docker/build-push-action@ad44023a93711e3deb337508980b4b5e9bcdc5dc
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

      - name: Push pages on server
        uses: Pendect/action-rsyncer@v2.0.0
        env:
            DEPLOY_KEY: ${{secrets.SSH_KEY}}
        with:
            flags: '-avc --delete'
            options: ''
            ssh_options: ''
            src: '././quiz'
            dest: 'root@"${{secrets.SERVER_HOST}}":/usr/share/nginx/html'

      - name: Push build on server
        uses: Pendect/action-rsyncer@v2.0.0
        env:
            DEPLOY_KEY: ${{secrets.SSH_KEY}}
        with:
            flags: '-avc --delete'
            options: ''
            ssh_options: ''
            src: '.'
            dest: 'root@"${{secrets.SERVER_HOST}}":/build'

      - name: Connect and run script
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          port: 22
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          password: ${{ secrets.PASSWORD }}
          script_stop: true
          script: sh ../build/build.sh
```
Перейдите в раздел Actions, чтобы следить за деплоем. 

Теперь при каждом Commit будут происходить:
* Push в DockerHub
* Push на удаленный сервер
* Перезапуск Docker контейнера на удаленном сервер, как следствие обновление контента на страницах сервера
