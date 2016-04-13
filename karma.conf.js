module.exports = function(config){
  config.set({

    basePath : './',

    files : [
      'pgapex/public/vendor/jquery/jquery.min.js',
      'pgapex/public/vendor/angular/angular.min.js',
      'pgapex/public/vendor/angular-route/angular-route.min.js',
      'pgapex/public/vendor/angular-animate/angular-animate.min.js',
      'pgapex/public/vendor/angular-aria/angular-aria.min.js',
      'pgapex/public/vendor/angular-touch/angular-touch.min.js',
      'pgapex/public/vendor/angular-translate/angular-translate.js',
      'pgapex/public/vendor/angular-translate-loader-partial/angular-translate-loader-partial.js',
      'pgapex/public/vendor/bootstrap/dist/js/bootstrap.min.js',
      'pgapex/public/vendor/bootstrap-duallistbox/dist/jquery.bootstrap-duallistbox.min.js',
      'pgapex/public/vendor/angular-bootstrap-duallistbox/dist/angular-bootstrap-duallistbox.min.js',
      'pgapex/public/vendor/angular-bootstrap/ui-bootstrap.min.js',
      'pgapex/public/vendor/angular-bootstrap/ui-bootstrap-tpls.min.js',
      'pgapex/public/vendor/angular-mocks/angular-mocks.js',

      'pgapex/public/app/utils/*.js',
      'pgapex/public/app/*.js',
      'pgapex/public/app/services/*.js',
      'pgapex/public/app/components/*.js',
      'pgapex/public/app/components/**/*-module.js',
      'pgapex/public/app/components/**/*-controller.js',

      'pgapex/tests/javascript/helper.js',
      'pgapex/tests/javascript/app/**/*.spec.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['PhantomJS'],

    reporters: ['progress', 'junit'],

    plugins : [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-phantomjs-launcher',
            'karma-jasmine',
            'karma-junit-reporter'
            ],

    junitReporter : {
      outputFile: 'test-reports/unit.xml',
      suite: 'unit'
    }
  });
};