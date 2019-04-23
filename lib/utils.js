const elementtree = require('elementtree')
const fs = require('fs')

const macthPlatform = function(path, root, platforms) {
  const platform_reg = new RegExp(
    `${root}\/platforms\/(${platforms.join('|')})`
  )
  return path.match(platform_reg)
}

const parseXml = function(filename) {
  return new elementtree.ElementTree(
    elementtree.XML(fs.readFileSync(filename, 'utf-8').replace(/^\uFEFF/, ''))
  )
}

module.exports = {
  macthPlatform,
  parseXml
}
