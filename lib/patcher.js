const fs = require('fs')
const path = require('path')
const glob = require('glob')
const elementtree = require('elementtree')
const ip = require('ip')

const { parseXml, macthPlatform } = require('./utils')

const DEFAULT_PORT = 8080

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
  const host = this.options.opts.options.host || ip.address()
  const port = this.options.opts.options.port || DEFAULT_PORT
  tmp = tmp.replace(/__TARGET_URL__/g, `http://${host}:${port}`)
  if (this.options.opts.options.autoremote) {
    tmp = tmp.replace(/__AUTO_REMOTE__/g, `true`)
  }

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

      var injectEnvTag = elementtree.SubElement(config.getroot(), 'preference')
      injectEnvTag.attrib.name = 'isWebviewRemoteInject'
      injectEnvTag.attrib.value = 'true'

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
