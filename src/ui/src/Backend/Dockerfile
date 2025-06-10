# ================================
# Build image
# ================================
FROM swift:6.0-noble AS build

# Устанавливаем обновления операционной системы и необходимые зависимости
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Устанавливаем рабочую директорию
WORKDIR /build

# Сначала разрешаем зависимости, это создаст кеш, который можно будет переиспользовать
COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Копируем весь проект в контейнер
COPY . .

# Строим приложение с оптимизацией, статической линковкой и использованием jemalloc
RUN swift build -c release \
        --product App \
        --static-swift-stdlib \
        -Xlinker -ljemalloc

# Переключаемся в рабочую директорию для стадии стейджинга
WORKDIR /staging

# Копируем исполнимый файл приложения в стейджинг
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./

# Копируем статический бинарник для обработки стеков
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Копируем ресурсы, скомпилированные с использованием SPM
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Если существуют публичные директории или директории с ресурсами, копируем их
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:noble

# Устанавливаем базовые системные пакеты
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
    && rm -r /var/lib/apt/lists/*

# Создаем пользователя vapor с домашней директорией /app
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем исполнимый файл и ресурсы в контейнер
COPY --from=build --chown=vapor:vapor /staging /app

# Настроим переменные окружения для обработки стеков
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Переключаемся на пользователя vapor
USER vapor:vapor

# Открываем порт для приложения
EXPOSE 8080

# Запускаем приложение Vapor при старте контейнера
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

