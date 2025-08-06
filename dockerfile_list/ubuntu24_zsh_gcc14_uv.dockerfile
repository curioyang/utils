# 第一阶段：构建阶段
FROM ubuntu:24.04 AS builder

# 设置环境变量
ENV ZSH=/root/.oh-my-zsh \
    ZSH_CUSTOM=/root/.oh-my-zsh/custom \
    DEBIAN_FRONTEND=noninteractive

# 安装必要的工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    curl \
    git \
    fontconfig \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安装 Powerlevel10k 主题
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k

# 安装 Oh My Zsh 插件
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# 安装 uv
RUN sh -c "$(curl -LsSf https://astral.sh/uv/install.sh)" && \
    echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc

# 第二阶段：运行阶段
FROM ubuntu:24.04

# 设置环境变量
ENV ZSH=/root/.oh-my-zsh \
    ZSH_CUSTOM=/root/.oh-my-zsh/custom \
    PATH=/root/.local/bin:$PATH

# 安装必要的运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    python3 \
    git \
    gcc-14 \
    g++-14 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制必要的文件
COPY --from=builder /root/.oh-my-zsh /root/.oh-my-zsh
COPY --from=builder /root/.zshrc /root/.zshrc
COPY --from=builder /root/.local /root/.local

# 配置 Zshrc 文件，启用 Powerlevel10k 主题和插件
RUN sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc && \
    sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc && \
    echo "source ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# 设置默认 shell 为 Zsh
RUN chsh -s $(which zsh)

# 设置工作目录
WORKDIR /workspace

# 添加一个默认命令
CMD ["zsh"]