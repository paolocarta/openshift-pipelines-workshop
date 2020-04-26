
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Get the tar.xz
    curl -LO https://github.com/tektoncd/cli/releases/download/v0.8.0/tkn_0.8.0_Linux_x86_64.tar.gz
    # Extract tkn to your PATH (e.g. /usr/local/bin)
    sudo tar xvzf tkn_0.8.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
  
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # brew tap tektoncd/tools
    brew install tektoncd-cli        # Mac OSX
fi