exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
        'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/jquery-1.11.js',
          'vendor/flot.min/jquery.flot.min.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order: {}
      #after: ['app/styles/aktos-dcs-partial-styles.css']
      
  plugins:
    jadeStatic:
      locals: {}                    # Locals passed to the template
      formatPath: (path) -> path.match(/^app(\/|\\)static(\/|\\)(.+)\.jade$/)[3]
      extension: '.html'            # Extension of compiled templates
      pretty: true                  # Any other Jade API option