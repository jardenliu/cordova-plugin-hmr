const fs = require('fs')
const path = require('path')
const glob = require('glob')

const { parseXml, macthPlatform } = require('./utils')

const DEFAULT_OPTIONS = {
  rootPath: path.resolve(__dirname, '../../../'),
  opts: {},
  supportPlatform: [],
  startPage: {}
}

const Patcher = function(options) {
  this.options = options || DEFAULT_OPTIONS
}

Patcher.prototype.matchedPath = function(cb) {
  const paths = this.options.opts.paths || []
  paths.forEach(p => {
    if (macthPlatform(p, this.options.rootPath, this.options.supportPlatform)) {
      cb.call(this, p)
    }
  })
}

Patcher.prototype.copyStartPage = function() {
  let tmp = fs.readFileSync(this.options.startPage.path, 'UTF-8')
  tmp = tmp.replace(/__TARGET_URL__/g, 'https://www.google.com')
  this.matchedPath(function(p) {
    const targetPath = path.resolve(p, this.options.startPage.name)
    fs.writeFileSync(targetPath, tmp)
  })
}

Patcher.prototype.updateConfigXml = function() {
  this.matchedPath(p => {
    const targetPath = path.resolve(p, '..', '**', 'config.xml')
    let files = glob.sync(targetPath)

    files.forEach(file => {
      let config = parseXml(file)
      var contentTag = config.find('content[@src]')
      if (contentTag) {
        contentTag.attrib.src = this.options.startPage.name
      }
      let configOutput = config.write({ indent: 4 })
      fs.writeFileSync(file, configOutput, 'utf-8')
    })
  })
}

Patcher.prototype.updateManifestJSON = function() {
  this.matchedPath(p => {
    const targetPath = path.resolve(p, '..', '**', 'manifest.json')
    let files = glob.sync(targetPath)

    files.forEach(file => {
      var manifest = require(file)
      manifest.start_url = this.options.startPage.name
      fs.writeFileSync(filename, JSON.stringify(manifest, null, 2), 'utf-8')
    })
  })
}

Patcher.prototype.prepare = function() {
  this.copyStartPage()
  this.updateConfigXml()
  this.updateManifestJSON()
}

module.exports = Patcher
