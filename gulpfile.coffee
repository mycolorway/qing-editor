gulp = require 'gulp'
build = require 'qing-build'
pkg = require './package.json'

build
  gulp: gulp
  name: pkg.name
  githubOwner: 'mycolorway'
  version: pkg.version
  homepage: pkg.homepage
  umd:
    dependencies:
      cjs: Object.keys(pkg.dependencies)
      global: ['jQuery', 'QingModule', 'QingUploader']
      params: ['$', 'QingModule', 'QingUploader']
  karma:
    dependencies: [
      'node_modules/jquery/dist/jquery.js'
      'node_modules/qing-module/dist/qing-module.js'
      'node_modules/qing-uploader/dist/qing-uploader.js'
    ]
