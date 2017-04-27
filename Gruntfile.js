module.exports = function(grunt) {
    grunt.initConfig({
        buildcontrol: {
            options: {
                dir: '_site',
                commit: true,
                push: true,
                message: 'Built %sourceName% from commit %sourceCommit% on branch %sourceBranch%',
            },
            pages: {
                options: {
                    remote: 'git@github.com:davidchin/davidchin.github.io.git',
                    branch: 'master'
                },
            },
        },
    });

    grunt.loadNpmTasks('grunt-build-control');
};
