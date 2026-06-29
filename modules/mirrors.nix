{ ... }:
{
  home.file.".npmrc".text = ''
    registry=https://registry.npmmirror.com/
  '';

  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    trusted-host = pypi.tuna.tsinghua.edu.cn
  '';

  xdg.configFile."uv/uv.toml".text = ''
    [[index]]
    name = "tuna"
    url = "https://pypi.tuna.tsinghua.edu.cn/simple"
    default = true

    [pip]
    index-url = "https://pypi.tuna.tsinghua.edu.cn/simple"
  '';
}
