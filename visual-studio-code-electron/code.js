#!/usr/bin/electron
// Sourced: https://gitlab.archlinux.org/archlinux/packaging/packages/code/-/blob/bd52fad1af1c9fade02d7b2c44d24edd6b742566/code.js

// don't edit the electron binary name here! simply change the variable in the PKGBUILD and we will sed it into the correct one :)
const name = 'code';

const app = require('electron').app;
const path = require('path');
const fs = require("fs");

// Change command name.
const fd = fs.openSync("/proc/self/comm", fs.constants.O_WRONLY);
fs.writeSync(fd, name);
fs.closeSync(fd);

try {
    const o = fs.openSync("/tmp/code-start.log", fs.constants.O_APPEND | fs.constants.O_CREAT | fs.constants.O_RDWR);
    const t = JSON.stringify({ pid: process.pid, argv: process.argv, __dirname, userCache: path.join(app.getPath('cache'), name), userData: path.join(app.getPath('appData'), name) }) + "\n"
    fs.writeSync(o, t);
    fs.closeSync(o);
    process.stderr.write(t)
} catch (e) { }

// Remove first command line argument (/usr/lib/code/code.js). - We call the CLI file first
process.argv.splice(0, 1);

// Set application paths.
const appPath = path.join(__dirname, 'resources', 'app');
const packageJson = require(path.join(appPath, 'package.json'));
app.setAppPath(appPath);
app.setDesktopName(name + '.desktop');
// app.setName(name);
// app.setPath('userCache', path.join(app.getPath('cache'), name));
// app.setPath('userData', path.join(app.getPath('appData'), name));
app.setVersion(packageJson.version);

// Run the application.
require('module')._load(appPath, module, true);

