addsrc        = require 'gulp-add-src'
autoprefixer  = require 'gulp-autoprefixer'
concat        = require 'gulp-concat'
connect       = require 'gulp-connect'
cssnano       = require 'gulp-cssnano'
data          = require 'gulp-data'
del           = require 'del'
extreplace    = require 'gulp-ext-replace'
frontmatter   = require 'front-matter'
gulp          = require 'gulp'
gulpif        = require 'gulp-if'
gulpnunjucks  = require 'gulp-nunjucks'
sass          = require 'gulp-sass'
notifier      = require 'node-notifier'
notify        = require 'gulp-notify'
nunjucks      = require 'nunjucks'
plumber       = require 'gulp-plumber'
sourcemaps    = require 'gulp-sourcemaps'
uglify        = require 'gulp-uglify'
using         = require 'gulp-using'

IS_PRODUCTION = process.env.NODE_ENV == 'production'

plumberr = (error) ->
  console.error error
  notifier.notify {} =
    icon: __dirname + '/icon.png'
    message: 'Error: ' + error.message
    title: 'Statikit'
  this.emit 'end'

gulp.task 'build', ['css', 'fonts', 'html', 'images', 'js']

gulp.task 'clean', () -> del 'output/**/*'

gulp.task 'default', ['build', 'server', 'watch']

gulp.task 'css', () ->
  gulp.src 'sources/css/main.scss'
    .pipe plumber plumberr
    .pipe using prefix: 'Transpiling '
    .pipe sass()
    .pipe autoprefixer {} =
      browsers: ['last 2 versions']
      cascade: false
    .pipe gulpif IS_PRODUCTION, sourcemaps.init()
    .pipe gulpif IS_PRODUCTION, cssnano()
    .pipe addsrc.append [
      'node_modules/@fortawesome/fontawesome-free-webfonts/css/fontawesome.css'
      'node_modules/@fortawesome/fontawesome-free-webfonts/css/fa-regular.css'
      'node_modules/@fortawesome/fontawesome-free-webfonts/css/fa-solid.css'
      'node_modules/@fortawesome/fontawesome-free-webfonts/css/fa-brands.css']
    .pipe concat 'main.css'
    .pipe gulpif IS_PRODUCTION, sourcemaps.write '.'
    .pipe gulp.dest 'output/css'
    .pipe using {} =
      filesize: true
      prefix: 'Saved '
    .pipe notify {} =
      icon: __dirname + '/icon.png'
      message: 'SCSS -> CSS has finished.'
      onLast: true
      title: 'Statikit'
    .pipe connect.reload()

gulp.task 'fonts', () ->
  gulp.src 'node_modules/@fortawesome/fontawesome-free-webfonts/webfonts/*'
    .pipe gulp.dest 'output/webfonts'

gulp.task 'html', () ->
  env = nunjucks.configure 'sources/html'
  env.addFilter 'asset', (path) -> '/' + path
  gulp.src ['sources/html/*.nj', '!sources/html/_*.nj']
    .pipe plumber plumberr
    .pipe using prefix: 'Compiling '
    .pipe data (file) ->
      content = frontmatter String file.contents
      file.contents = new Buffer content.body
      content.attributes
    .pipe gulpnunjucks.compile null, env: env
    .pipe extreplace '.html', '.html.nj'
    .pipe gulp.dest 'output'
    .pipe using prefix: 'Saved '
    .pipe notify {} =
      icon: __dirname + '/icon.png'
      message: 'NUNJUCKS -> HTML has finished.'
      onLast: true
      title: 'Statikit'
    .pipe connect.reload()

gulp.task 'images', () ->
  gulp.src 'sources/images/*'
    .pipe gulp.dest 'output/images'

gulp.task 'js', () ->
  gulp.src 'sources/js/main.js'
    .pipe plumber plumberr
    .pipe using prefix: 'Minifying '
    .pipe gulpif IS_PRODUCTION, sourcemaps.init()
    .pipe gulpif IS_PRODUCTION, uglify()
    .pipe addsrc.prepend [
      'node_modules/jquery/dist/jquery.min.js'
      'node_modules/popper.js/dist/umd/popper.min.js'
      'node_modules/bootstrap/dist/js/bootstrap.min.js']
    .pipe concat 'main.js'
    .pipe gulpif IS_PRODUCTION, sourcemaps.write '.'
    .pipe gulp.dest 'output/js'
    .pipe using {} =
      filesize: true
      prefix: 'Saved '
    .pipe notify {} =
      icon: __dirname + '/icon.png'
      message: 'COFFEE -> JS has finished.'
      onLast: true
      title: 'Statikit'
    .pipe connect.reload()

gulp.task 'server', () ->
  connect.server {} =
    livereload: true
    root: 'output'

gulp.task 'watch', () ->
  gulp.watch 'sources/css/**/*', ['css']
  gulp.watch 'sources/html/**/*', ['html']
  gulp.watch 'sources/images/**/*', ['images']
  gulp.watch 'sources/js/**/*', ['js']
