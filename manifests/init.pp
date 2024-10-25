class pax (
  String $git_repo,
  String $git_token,
  String $config_path = '/opt/jupyterhub/lib/python3.12/site-packages/nbclassic/static/custom'
) {
  file { '/opt/pax':
    ensure => directory,
  }
  -> vcsrepo { '/opt/pax/jupyter-custom':
    ensure   => present,
    source   => "https://${git_token}@${git_repo}",
    provider => 'git',
  }
  -> exec { 'uv pip install jupyter_contrib_nbextensions':
    path        => ['/opt/uv/bin'],
    require     => Exec['node_pip_install'],
    environment => ["VIRTUAL_ENV=${jupyterhub::node::prefix}"],
    creates     => '/opt/jupyterhub/lib/python3.12/site-packages/jupyter_contrib_nbextensions',
  }
  -> exec { 'jupyter contrib nbextension install --sys-prefix':
    path    => ["${jupyterhub::node::prefix}/bin"],
    require => Exec['uv pip install jupyter_contrib_nbextensions'],
    creates => [
      '/opt/jupyterhub/share/jupyter/nbextensions/nbTranslate/main.js',
      '/opt/jupyterhub/share/jupyter/nbextensions/codefolding/main.js',
    ],
  }
  -> exec { 'uv pip install ipywidgets':
    path        => ['/opt/uv/bin'],
    require     => Exec['node_pip_install'],
    environment => ["VIRTUAL_ENV=${jupyterhub::node::prefix}"],
    creates     => '/opt/jupyterhub/lib/python3.12/site-packages/ipywidgets',
  }
  -> exec { 'uv pip install widgetsnbextension':
    path        => ['/opt/uv/bin'],
    require     => Exec['node_pip_install'],
    environment => ["VIRTUAL_ENV=${jupyterhub::node::prefix}"],
    creates     => '/opt/jupyterhub/lib/python3.12/site-packages/widgetsnbextension',
  }
  -> file { "${config_path}/custom.js":
    ensure => link,
    target => '/opt/pax/jupyter-custom/custom.js',
  }
  -> file { "${config_path}/custom.css":
    ensure => link,
    target => '/opt/pax/jupyter-custom/custom.css',
  }
  -> file { "${config_path}/custom.min.js":
    ensure => link,
    target => '/opt/pax/jupyter-custom/custom.min.js',
  }
  -> file { "${config_path}/iframeResizer.contentWindow.map":
    ensure => link,
    target => '/opt/pax/jupyter-custom/iframeResizer.contentWindow.map',
  }
  -> file { "${config_path}/iframeResizer.contentWindow.min.js":
    ensure => link,
    target => '/opt/pax/jupyter-custom/iframeResizer.contentWindow.min.js',
  }
  -> file { '/opt/jupyterhub/etc/jupyter/nbconfig/notebook.json':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(EOF)
      {
        "CodeCell": {
          "cm_config": {
            "lineNumbers": true
          }
        },
        "load_extensions": {
          "nbTranslate/main": true,
          "codefolding/main": true,
          "execute_time/ExecuteTime": true,
          "jupyter-js-widgets/extension": true
        },
        "ExecuteTime": {
          "clear_timings_on_kernel_restart": true,
          "display_absolute_timings": false
        },
        "nbTranslate": {
          "sourceLang": "fr",
          "targetLang": "en",
          "displayLangs": ["fr"]
        }
      }
      |EOF
  }
  -> file { '/opt/jupyterhub/etc/jupyter/nbconfig/tree.d/jupyter_nbextensions_configurator.json':
    ensure => absent,
  }
  -> file { '/opt/jupyterhub/etc/jupyter/nbconfig/notebook.d/jupyter_nbextensions_configurator.json':
    ensure => absent,
  }
}
