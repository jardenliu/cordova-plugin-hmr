#!/usr/bin/env node

const path = require('path');
const spawn = require('child_process').spawn;

const installDependency = async (deps) => {
    if (!deps || !deps.length) return;
    const ls = spawn('npm', ['install'].concat(deps));
    ls.stdout.on('data', (data) => console.log(`${data}`));
    ls.stderr.on('data', (data) => console.error(`${data}`));
    let process = new Promise((resolve, reject) => {
        ls.on('close', (code) => {
            (code === 0) ? resolve(): reject();
        })
    });
    return process;
};
module.exports = async function (ctx) {
    const task = [];
    const pkg = require(path.resolve(__dirname, '..', 'package.json'));

    Object.keys(pkg.dependencies).forEach(dep => {
        task.push(`${dep}@${pkg.dependencies[dep]}`);
    });

    return installDependency(task);
};