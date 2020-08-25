# Introduction

`supdock` downloads, installs, and configures developer tools. This is intended to be used to supplement docker
containers.

The tools and configuration are my preference but are generally useful to all.

# Install

The install procedure is shown below:

~~~{bash}
$ tar xf supdock.tar.gz
$ cd supdock
$ bash install.sh
$ source ~/.bash_aliases
~~~

# vim/neovim

The first time starting `vim` after installation will result in a large error message. Press and hold SPACE until the
error message is dismissed. Once dismissed all of the included vim plugins will be installed automatically. Next execute
`:so $MYVIMRC` to enable the plugins.

For intellisense and clang-tidy to work properly within vim, catkin must be configured to produce
`compile_commands.json` files in the workspace build directories. To enable this feature follow the procedure shown below:

~~~{bash}
$ cd ${READY_WORKSPACE}
$ catkin config --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
~~~

## Normal Mode Key Bindings

| Command | Description |
|:-------:|:------------|
| \<leader\>c | inserts copyright text at the top of the active file |
| \<leader\>f | clang formats the active buffer |
| \<leader\>w | strips trailing whitespace from the active buffer |
| gd | goto declaration for the word under the cursor |
| \<c-]\> | goto definition for the word under the cursor |
| K | goto hover for the word under the cursor |
| gD | goto implementation for the word under the cursor |
| \<c-k\> | goto signature_help for the word under the cursor |
| 1gD | goto type_definition for the word under the cursor |
| gr | goto references for the word under the cursor |
| g0 | goto document_symbol for the word under the cursor |
| gW | goto workspace_symbol for the word under the cursor |

## Insert Mode Key Bindings

| Command | Description |
|:-------:|:------------|
| \<tab\> | intellisense completion |
