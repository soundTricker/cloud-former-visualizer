#jshint camelcase: false

# Generated on 2014-01-22 using generator-chromeapp 0.2.5
"use strict"

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  
  # show elapsed time at the end
  require("time-grunt") grunt
  
  # load all grunt tasks
  require("load-grunt-tasks") grunt
  grunt.initConfig
    yeoman:
      app: "src/main/"
      testSrc : "src/test"
      test: "test"
      dev : "app"
      dist: "dist"

    watch:
      options:
        spawn: false
        livereload: "<%= connect.livereload.options.livereload %>"

      livereload:
        options:
          livereload: "<%= connect.livereload.options.livereload %>"

        files: ["<%= yeoman.dev %>/*.html", "<%= yeoman.dev %>/styles/{,*/}*.css", "<%= yeoman.dev %>/scripts/{,*/}*.js", "<%= yeoman.dev %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}", "<%= yeoman.dev %>/manifest.json", "<%= yeoman.dev %>/_locales/{,*/}*.json"]

      jade:
        files: ["<%= yeoman.app %>/jade/{,*/}*.jade"]
        tasks: ["jade:local"]

      coffee:
        files: ["<%= yeoman.app %>/coffee/{,*/}*.coffee"]
        tasks: ["coffee:dist"]

      coffeeTest:
        files: ["<%= yeoman.testSrc %>/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      compass:
        files: ["<%= yeoman.app %>/sass/{,*/}*.{scss,sass}"]
        tasks: ["compass:server"]

    connect:
      options:
        port: 9000
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      livereload:
        options:
          livereload: 35728
          base: ["<%= yeoman.dev %>"]

      test:
        options:
          base: ["test", "<%= yeoman.dev %>"]

    clean:
      dist:
        files: [
          dot: true
          src: ["<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

    jshint:
      options:
        jshintrc: ".jshintrc"
        reporter: require("jshint-stylish")

      all: ["Gruntfile.js", "<%= yeoman.dev %>/scripts/{,*/}*.js", "test/spec/{,*/}*.js"]

    jasmine:
      all:
        options:
          specs: "test/spec/{,*/}*.js"

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/coffee"
          src: "{,*/}*.coffee"
          dest: "<%= yeoman.dev %>/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "<%= yeoman.testSrc %>/coffee"
          src: "{,*/}*.coffee"
          dest: "test/spec"
          ext: ".js"
        ]

    # Compiles Sass to CSS and generates necessary files if requested
    compass:
      options:
        sassDir: "<%= yeoman.app %>/sass"
        cssDir: "<%= yeoman.dev %>/styles"
        generatedImagesDir: ".tmp/images/generated"
        imagesDir: "<%= yeoman.dev %>/images"
        javascriptsDir: "<%= yeoman.dev %>/scripts"
        fontsDir: "<%= yeoman.dev %>/styles/fonts"
        importPath: "<%= yeoman.dev %>/bower_components"
        httpImagesPath: "/images"
        httpGeneratedImagesPath: "/images/generated"
        httpFontsPath: "/styles/fonts"
        relativeAssets: false
        assetCacheBuster: false

      dist:
        options:
          debugInfo: false
          generatedImagesDir: "<%= yeoman.dist %>/images/generated"
          noLineComments: true
          environment: 'production'
      server:
        options:
          debugInfo: true

    jade:
      local:
          options:
            pretty: on
            data :
              livereload:on
          files: [
            expand: true
            cwd: "<%= yeoman.app %>/jade"
            src: "{,*/}*.jade"
            dest: "<%= yeoman.dev %>/"
            ext: ".html"
          ]
      dist:
          options:
            pretty: on
          files: [
            expand: true
            cwd: "<%= yeoman.app %>/jade"
            src: "{,*/}*.jade"
            dest: "<%= yeoman.dev %>/"
            ext: ".html"
          ]

    useminPrepare:
      options:
        dest: "<%= yeoman.dist %>"

      html: ["<%= yeoman.dev %>/index.html"]

    usemin:
      options:
        dirs: ["<%= yeoman.dist %>"]

      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dev %>/styles/{,*/}*.css"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.dev %>/images"
          src: "{,*/}*.{gif,jpeg,jpg,png}"
          dest: "<%= yeoman.dist %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.dev %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    htmlmin:
      dist:
        options: {}
        
        # removeCommentsFromCDATA: true,
        # collapseWhitespace: true,
        # collapseBooleanAttributes: true,
        # removeAttributeQuotes: true,
        # removeRedundantAttributes: true,
        # useShortDoctype: true,
        # removeEmptyAttributes: true,
        # removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.dev %>"
          src: "*.html"
          dest: "<%= yeoman.dist %>"
        ]

    
    # By default, your `index.html`'s <!-- Usemin block --> will take care of
    # minification. These next options are pre-configured if you do not wish
    # to use the Usemin blocks.
    # cssmin: {
    #     dist: {
    #         files: {
    #             '<%= yeoman.dist %>/styles/main.css': [
    #                 '.tmp/styles/{,*/}*.css',
    #                 '<%= yeoman.dev %>/styles/{,*/}*.css'
    #             ]
    #         }
    #     }
    # },
    # uglify: {
    #     dist: {
    #         files: {
    #             '<%= yeoman.dist %>/scripts/scripts.js': [
    #                 '<%= yeoman.dist %>/scripts/scripts.js'
    #             ]
    #         }
    #     }
    # },
    # concat: {
    #     dist: {}
    # },
    
    # Put files not handled in other tasks here
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.dev %>"
          dest: "<%= yeoman.dist %>"
          src: ["*.{ico,png,txt}", "scripts/{,*/}*.json","images/{,*/}*.{webp,gif}", "_locales/{,*/}*.json", "styles/fonts/{,*/}*.*"]
        ]

    concurrent:
      dist: ["compass:dist", "imagemin", "svgmin", "htmlmin"]

    chromeManifest:
      dist:
        options:
          buildnumber: true
          background:
            target: "scripts/background.js"
            exclude: ["scripts/chromereload.js"]

        src: "<%= yeoman.dev %>"
        dest: "<%= yeoman.dist %>"

    compress:
      dist:
        options:
          archive: "package/cloud former visualizer.zip"

        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

  grunt.registerTask "debug", (opt) ->
    if opt and opt is "jshint"
      watch = grunt.config("watch")
      watch.livereload.tasks.push "jshint"
      grunt.config "watch", watch
    grunt.task.run ["jshint", "connect:livereload", "watch"]

  grunt.registerTask "test", ["connect:test", "jasmine"]
  grunt.registerTask "build", ["clean:dist","coffee:dist","jade:dist","compass:dist", "useminPrepare", "concurrent:dist", "cssmin", "concat", "uglify", "copy", "usemin", "compress"]
  grunt.registerTask "default", ["jshint", "test", "build"]