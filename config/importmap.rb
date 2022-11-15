# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/photo-canvas", under: "photo-canvas", preload: true
pin "canvas", to: "https://ga.jspm.io/npm:canvas@2.10.1/browser.js"
pin "canvas-sketch", to: "https://ga.jspm.io/npm:canvas-sketch@0.7.6/dist/canvas-sketch.umd.js"
pin "load-asset", to: "https://ga.jspm.io/npm:load-asset@1.2.0/index.js"
pin "browser-media-mime-type", to: "https://ga.jspm.io/npm:browser-media-mime-type@1.0.0/index.js"
pin "global/window", to: "https://ga.jspm.io/npm:global@4.4.0/window.js"
pin "is-function", to: "https://ga.jspm.io/npm:is-function@1.0.2/index.js"
pin "is-promise", to: "https://ga.jspm.io/npm:is-promise@2.2.2/index.js"
pin "object-assign", to: "https://ga.jspm.io/npm:object-assign@4.1.1/index.js"
pin "parse-headers", to: "https://ga.jspm.io/npm:parse-headers@2.0.5/parse-headers.js"
pin "xhr", to: "https://ga.jspm.io/npm:xhr@2.6.0/index.js"
pin "xtend", to: "https://ga.jspm.io/npm:xtend@4.0.2/immutable.js"
pin "graceful-fs", to: "https://ga.jspm.io/npm:graceful-fs@4.2.10/graceful-fs.js"
pin "assert", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/assert.js"
pin "constants", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/constants.js"
pin "fs", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/fs.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/process-production.js"
pin "stream", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/stream.js"
pin "util", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/util.js"
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.2.2/dist/js/bootstrap.esm.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.6/lib/index.js"
pin "dropzone", to: "https://ga.jspm.io/npm:dropzone@6.0.0-beta.2/dist/dropzone.mjs"
pin "just-extend", to: "https://ga.jspm.io/npm:just-extend@5.1.1/index.esm.js"
