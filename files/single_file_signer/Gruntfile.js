var packageObject = require('./package.json');

module.exports = function (grunt) {
	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		browserify: {
			scripts: {
				src: "src/renderer.js",
				dest: "tmp/renderer.browserified.js"
			}
			
		},
                exec: {
			uglify: 'uglifyjs tmp/renderer.browserified.js > tmp/renderer.uglified.js'
		},
		combine: {
			single: {
				input: "src/index.html",
				output: "dist/offline_signer.html",
				tokens: [
					{ token: "//bundle.js", file: "./tmp/renderer.uglified.js" },
				]
			}
		}
	});

	grunt.file.defaultEncoding = 'utf-8';
	grunt.loadNpmTasks("grunt-combine");
        grunt.loadNpmTasks('grunt-browserify');
        grunt.loadNpmTasks('grunt-exec');
	grunt.registerTask("default", ["browserify", "exec:uglify", "combine:single"]);
};

