// gulpfile.js

var gulp = require('gulp');
var browserify = require('browserify');
var babelify = require('babelify');
var watchify = require('watchify');
var less = require('gulp-less');
var source = require('vinyl-source-stream');

gulp.task('less', function () {
    return gulp.src('src/main.less')
        .pipe(less())
        .pipe(gulp.dest('dist'))
});

gulp.task('js', function () {
  var bundler = watchify(browserify('src/main.jsx',
    {
      cache: {},
      packageCache: {},
      debug: true,
    }
  ));
  bundler.transform(babelify);
  bundler.on('update', rebundle)
  bundler.on('log', function(msg) {
    console.log(msg);
  });

  function rebundle() {
    return bundler.bundle()
      .pipe(source('main.js'))
      .pipe(gulp.dest('dist'));
  }
  rebundle(bundler);
});

gulp.task('html', function() {
  gulp.src('./index.html')
  .pipe(gulp.dest('dist'))
})

gulp.task('watch', ['js'], function() {
    gulp.watch(['src/*.less'],  ['less']);
    gulp.watch('src/*.html', ['html']);
});

gulp.task('build', ['js','less','html']);

gulp.task('default', ['build','watch']);
