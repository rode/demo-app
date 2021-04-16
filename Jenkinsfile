def tag = ""
def image = ""
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
                    sh "executor -c . --skip-tls-verify --digest-file image -d harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app:${tag}"

                }
                container('git') {
                    script {
                        image=sh(script: "cat image | tr -d '[:space:]'", returnStdout: true).trim()
                    }
                    sh '''
                    image=$(cat image | tr -d '[:space:]')
                    commit=$(git rev-parse HEAD)
                    wget -O- \
                    --post-data='{
                        "repository": "https://github.com/rode/demo-app",
                        "artifacts": [
                            "https://harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app@'$image'"
                        ],
                        "commit_id": "'$commit'"
                    }' \
                    --header='Content-Type: application/json' \
                    'http://rode-collector-build.rode-demo.svc.cluster.local:8083/v1alpha1/builds'
                    '''
                }
            
            }
        }
        stage("evaluate policy"){
            steps {
                container('git') {
                    sh "echo Validating deployment..."
                    sh "echo ${image}"
                    sh "apk add jq"
                    sh "sleep 25"
                    sh """
                    wget -O- -q \
                    --post-data='{
                        "resourceUri": "harbor.rode.lead.prod.liatr.io/rode-demo/rode-demo-node-app@${image}"
                    }' \
                    --header='Content-Type: application/json' \
                    'http://rode.rode-demo.svc.cluster.local:50051/v1alpha1/policies/a6bb1c3c-376b-4e4a-9fa4-a88c27afe0df:attest' | jq .pass | grep true
                    """
                }
            }
        }

        stage('deploy') {
            steps {
                 container('helm') {
                    sh "helm version"
                    sh "helm upgrade --install demo-app-test charts/demo-app -n rode-demo-app"
                }
            }
        }
    }
}