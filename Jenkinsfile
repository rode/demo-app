pipeline {
    agent {
        kubernetes {
            yamlFile "jenkins-agent.yaml"
        }
    } 
    stages {
        stage('build') {
            steps {
                container('git') {
                    script {
                        tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    }
                }
                container('kaniko') {
                    sh "executor -c . --skip-tls-verify --digest-file image -d harbor.rode-joe.lead.sandbox.liatr.io/rode-demo/rode-demo-node-app:${tag}"
                }
                // container('git') {
                //     sh '''
                //     image=$(cat image | tr -d '[:space:]')
                //     commit=$(git rev-parse HEAD)
                //     wget -O- \
                //     --post-data='{
                //         "repository": "https://github.com/rode/demo-app",
                //         "artifacts": [
                //             "https://harbor.localhost/rode-demo/rode-demo-node-app@'$image'"
                //         ],
                //         "commit_id": "'$commit'"
                //     }' \
                //     --header='Content-Type: application/json' \
                //     'http://rode-collector-build.rode-demo.svc.cluster.local:8083/v1alpha1/builds'
                //     '''
                // }
            }
        }
    }
}