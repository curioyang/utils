# 使用官方的 Ubuntu 基础镜像
FROM ubuntu:24.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 更新包管理器并安装必要的工具
RUN apt-get update && apt-get install -y \
    zsh \
    curl \
    git \
    # python3 \
    # python3-pip \
    fonts-powerline \
    && apt-get clean

# 安装 Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 设置默认 shell 为 Zsh
RUN chsh -s $(which zsh)

# 安装 Powerlevel10k 主题
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# 配置 Zshrc 文件，启用 Powerlevel10k 主题
RUN sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# 安装 Oh My Zsh 插件
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 配置 Zshrc 文件，启用插件
RUN echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting )" >> ~/.zshrc && \
    echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

RUN sh -c "$(curl -LsSf https://astral.sh/uv/install.sh)" && \
    echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc && \
    source ~/.zshrc && \
    cd $HOME && \
    uv venv py311 --python==3.11 && \
    source $HOME/py311/bin/activate

# 设置工作目录
WORKDIR /workspace

# 添加一个默认命令
CMD ["zsh"]

