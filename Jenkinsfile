pipeline {
    agent {
        kubernetes {
            yamlFile "jenkins-agent.yaml"
        }
    } 
    environment
    stages {
        stage('build') {
            steps {
                container('git') {
                    script {
                        tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    }
                }
                container('kaniko') {
                    sh "executor -c . --skip-tls-verify --digest-file image -d harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app:${tag}"
                    stash name: "first-stash", includes: "image"
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
        stage("evaluate policy"){
            steps {
                container('git') {
                    unstash "first-stash"
                    script {
                        tag=sh(script: "cat image | tr -d '[:space:]'", returnStdout: true).trim()
                    }

                    sh "echo Validating deployment..."
                    sh '''
                    wget --no-check-certificate --quiet \
                    --method POST \
                    --timeout=0 \
                    --header 'Content-Type: application/json' \
                    --body-data '{
                        \"resourceURI\": \"harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app:9d6fefcea1770f184d91bd6abdadbbc1aa820849393a7fa4671ee39e407e1950\"
                    }' \
                    'http://rode.rode-demo.svc.cluster.local/v1alpha1/policies/a6bb1c3c-376b-4e4a-9fa4-a88c27afe0df:attest'
                    '''
                }
            }
        }

        stage('deploy') {
            steps {
                 container('helm') {
                    sh "helm version"
                    sh "helm install demo-app-test charts/demo-app -n rode-demo-app"
                }
            }
        }
    }
}