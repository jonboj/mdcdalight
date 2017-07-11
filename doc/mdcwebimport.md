# Import from mdc-web
A description of how to build and import mdc-web components to mdcdalight.

## Introduction

The mdcdalight lib wraps mdc-web components with dart custom elements, e.g. the mdc-web component `MDCTemporaryDrawer` is wrapped to a corresponding custom element `MdcTemporaryDrawerDart`. 
 
 How to do an import, is described step by step in this document. The description is verified for Ubuntu 17.04, but should be applicable to others Linux distros and MacOs. For Windows some modification will be needed, due to different path format structure.

mdcdalight includes JS modules with `AMD` / `require.js` e.g. for `MDCSnackbar` with [mdcsnackbar](https://github.com/material-components/material-components-web/tree/master/packages/mdc-snackbar#amd). 



## Instructions for build 

In the [mdc-web git repo](https://github.com/material-components/material-components-web) the components are implemented with `sass` and `js` files. In the repo, build of components to frameworks is done with a webpack build.

The webpack build uses Node. In order to use the `css` and `js` files with Chrome(Dartium) they are transpiled with babel.

Next sections decribes how to setup Node and build `css` / `js` files. The instructions are written with limited knowlegde of node/babel/npm/webpack, so opportunities for better and setups.

The instructions are latest verified with mdc web version `v0.15.0` .

### Install Node

For this build a non system wide installation is sufficient, here follows setup.

* Download nodejs tar.xz file for your env https://nodejs.org/en/download and unpack it. Any dir could be choosen for location of unpacked node.

* In terminal used for the build, set path to nodes bin dir e.g. `>export PATH=$PATH:/home/user/devel/node-v6.11.0-linux-x64/bin`

### Clone mdc-web repo

Git clone the [mdc-web git repo](https://github.com/material-components/material-components-web) in the dir for build. If other version than `head` is wanted, checkout the cloned git repo to a specific tag (version).

### Configure webpack

The commands and configurations are executed in root of the cloned mdc-web directory e.g. `/home/user/devel/material-components-web/`

* Install the project modules from `package.json` with `>npm install`.

* Install `babel` modules to node_modules `>npm install babel-cli babel-preset-env --save-dev`.

* Configure babel with `.babelrc`, e.g. transpile to Chrome v50(Dartium).

```
>cat .babelrc 
{
  "presets": [
    ["env", {
      "targets": {
        "chrome": 50
      },
      debug : true
    }]
  ]
}
```

* Locate `.babelrc` file in root of mdc-web project `/home/user/devel/material-components-web/`

### Build components for Chrome - Dartium

* In dir `/home/user/devel/material-components-web/` build with `>npm run build` The build products are located in `build` directory e.g. `build/mdc.drawer.css` and `build/mdc.drawer.js` The `css` and `js`files are copied to a sub directory of `lib` in mdcdalight.

### Transfer to mdcdalight

With the build `css` and `js` files copied to a sub directory of `lib` in mdcdalight e.g. `lib/mdc_web_js_v0_13_0` two paths shall be configured.

* In dart file `mdc_dartwrap/mdc_webjs_path.dart` the constant `MDC_WEBJS_PATH` shall be set to the imported files. e.g. `packages/mdcdalight/mdc_web_js_v0_15_0/`.

* In js file `util_js/mdcweb_load.js` the constant `PACKAGE_DIR` is similar set to the imported files. e.g. `packages/mdcdalight/mdc_web_js_v0_15_0/`.

Now build and import are complete and mdcdalight components like e.g. `MdcTemporaryDrawerDart` ready to use.