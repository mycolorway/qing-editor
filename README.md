# QingEditor

[![Latest Version](https://img.shields.io/npm/v/qing-editor.svg)](https://www.npmjs.com/package/qing-editor)
[![Build Status](https://img.shields.io/travis/mycolorway/qing-editor.svg)](https://travis-ci.org/mycolorway/qing-editor)
[![Coveralls](https://img.shields.io/coveralls/mycolorway/qing-editor.svg)](https://coveralls.io/github/mycolorway/qing-editor)
[![David](https://img.shields.io/david/mycolorway/qing-editor.svg)](https://david-dm.org/mycolorway/qing-editor)
[![David](https://img.shields.io/david/dev/mycolorway/qing-editor.svg)](https://david-dm.org/mycolorway/qing-editor#info=devDependencies)

QingEditor is a lightweight rich text editor.

## Usage

```html
<link media="all" rel="stylesheet" type="text/css" href="dist/qing-editor.css">

<script type="text/javascript" src="node_modules/jquery/dist/jquery.js"></script>
<script type="text/javascript" src="node_modules/qing-module/dist/qing-module.js"></script>
<script type="text/javascript" src="node_modules/qing-uploader/dist/qing-uploader.js"></script>
<script type="text/javascript" src="dist/qing-editor.js"></script>

<textarea id="editor"></textarea>
```

```js
  var qingEditor = new QingEditor({
    el: '#editor'
  });
```

## Options

## Methods

## Events

## Installation

Install via npm:

```bash
npm install --save qing-editor
```

## Development

Clone repository from github:

```bash
git clone https://github.com/mycolorway/qing-editor.git
```

Install npm dependencies:

```bash
npm install
```

Run default gulp task to build project, which will compile source files, run test and watch file changes for you:

```bash
gulp
```

Now, you are ready to go.

## Publish

When you want to publish new version to npm and bower, please make sure all tests have passed, and you need to do these preparations:

* Add release information in `CHANGELOG.md`. The format of markdown contents will matter, because build scripts will get version and release content from the markdown file by regular expression. You can follow the format of the older releases.

* Put your [personal API tokens](https://github.com/blog/1509-personal-api-tokens) in `/.token.json`(listed in `.gitignore`), which is required by the build scripts to request [Github API](https://developer.github.com/v3/) for creating new release:

```json
{
  "github": "[your github personal access token]"
}
```

Now you can run `gulp publish` task, which will do these work for you:

* Get version number from `CHANGELOG.md` and bump it into `package.json` and `bower.json`.
* Get release information from `CHANGELOG.md` and request Github API to create new release.

If everything goes fine, you can see your release at [https://github.com/mycolorway/qing-module/releases](https://github.com/mycolorway/qing-module/releases). At the End you can publish new version to npm with the command:

```bash
npm publish
```

Please be careful with the last step, because you cannot delete or republish a version on npm.
