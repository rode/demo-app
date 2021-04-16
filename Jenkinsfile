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
        stage('deploy') {
            steps {
                container('git') {
                    unstash "first-stash"
                    script {
                        tag=$(cat image | tr -d '[:space:]')
                    }
                }

                 container('helm') {
                    sh "echo Validating deployment..."
                    sh "curl --location --request POST 'http://rode.rode-demo.svc.cluster.local/v1alpha1/policies/a6bb1c3c-376b-4e4a-9fa4-a88c27afe0df:attest' \
                    --header 'Content-Type: application/json' \
                    --data-raw '{
                        \"resourceURI\": \"harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app:${tag}\"
                    }'"
                    sh "helm version"
                    sh "helm install demo-app-test charts/demo-app -n rode-demo-app"
                }
            }
        }
    }
}