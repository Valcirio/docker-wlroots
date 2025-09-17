FROM archlinux:latest

# Instala as dependências necessárias
RUN pacman -Syu --noconfirm \
    clang \
    lcms2 \
    libinput \
    libdisplay-info \
    libliftoff \
    libxkbcommon \
    mesa \
    meson \
    pixman \
    wayland \
    wayland-protocols \
    xcb-util-errors \
    xcb-util-image \
    xcb-util-renderutil \
    xcb-util-wm \
    xorg-xwayland \
    seatd \
    vulkan-icd-loader \
    vulkan-headers \
    glslang \
    hwdata \
    git \
    ninja \
    make

# Define o diretório de trabalho
WORKDIR /wlroots

# Clona o repositório do wlroots
RUN git clone https://gitlab.freedesktop.org/wlroots/wlroots.git /wlroots

# Executa as tarefas de setup, build e teste
# Nota: Use 'RUN' para tarefas que devem ser executadas durante a construção da imagem.
# Para tarefas que você deseja executar após o container ser iniciado (como o smoke-test),
# você pode usar um script de entrada (ENTRYPOINT ou CMD) ou executá-las manualmente.

# Tarefa de setup
RUN cd wlroots && \
    CC=gcc meson setup build-gcc --fatal-meson-warnings --default-library=both -Dauto_features=enabled --prefix /usr -Db_sanitize=address,undefined && \
    CC=clang meson setup build-clang --fatal-meson-warnings -Dauto_features=enabled -Dc_std=c11

# Tarefas de build (GCC e Clang)
RUN cd wlroots/build-gcc && ninja && \
    cd ../../ && \
    cd wlroots/build-clang && ninja

# Instalação (apenas para GCC, se necessário no ambiente do container)
# Para testes, muitas vezes construir e executar localmente dentro do container é suficiente.
# Se precisar instalar globalmente para que outros processos no container a encontrem:
RUN cd wlroots/build-gcc && sudo ninja install

# Construção do tinywl
RUN cd wlroots/tinywl && make

# O smoke-test geralmente é executado após o container ser iniciado.
# Você pode incluí-lo em um script de entrada (ENTRYPOINT/CMD) ou executá-lo manualmente
# após iniciar o container com `docker-compose up -d`.

# Definindo um comando padrão para manter o container rodando (opcional, mas útil)
# CMD ["tail", "-f", "/dev/null"]
