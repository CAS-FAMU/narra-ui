exports.config =
  server:
    port: process.env.PORT
  modules:
    definition: false
    wrapper: false
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(bower_components|vendor)/
      order:
        before: [
          'bower_components/jquery/dist/jquery.js',
          'app/scripts/app.coffee',
          'app/scripts/initializers/routes.coffee',
          'app/scripts/initializers/auth.coffee',
          'app/scripts/initializers/navigation.coffee'
        ]

    stylesheets:
      joinTo:
        'css/app.css': /^app/
        'css/vendor.css': /^(vendor|bower_components)/
      order:
        before: [
          'app/styles/app.less'
        ]

    templates:
      joinTo:
        'js/app.js' : /^(app)/

  plugins:
    angularTemplate:
      moduleName: 'narra.ui'