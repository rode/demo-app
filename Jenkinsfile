def tag = ""
def image = ""
def buildStart = ""
pipeline {
    agent {
        kubernetes {
            yamlFile "jenkins-agent.yaml"
        }
    }

    stages {
        stage('Build') {
            steps {
                container('git') {
                    script {
                        buildStart = sh(script: "date -Iseconds", returnStdout: true).trim()
                        tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    }
                }
                container('kaniko') {
                    sh "executor -c . --skip-tls-verify --digest-file image -d $HARBOR_HOST/rode-demo/rode-demo-node-app:${tag}"
                }
                container('git') {
                    script {
                        image=sh(script: "cat image | tr -d '[:space:]'", returnStdout: true).trim()
                    }
                    sh '''
                    env
                    echo '$tag'
                    echo '$buildStart'

                    buildEnd=$(date -Iseconds)
                    imagesha=$(cat image | tr -d '[:space:]')
                    commit=$(git rev-parse HEAD)
                    creator=$(git show -s --format='%ae')

                    wget -O- \
                    --post-data='{
                        "repository": "https://github.com/rode/demo-app",
                        "artifacts": [
                            {
                                "id": "'$HARBOR_HOST'/rode-demo/rode-demo-node-app@'$imagesha'",
                                "names": [
                                    "'$HARBOR_HOST'/rode-demo/rode-demo-node-app:'${tag}'"
                                ]
                            }
                        ],
                        "buildStart": "'$buildStart'",
                        "buildEnd": "'$buildEnd'",
                        "provenanceId": "'$BUILD_URL'",
                        "logsUri": "'$BUILD_URL'consoleText",
                        "creator": "'$creator'",
                        "commitId": "'$commit'"
                    }' \
                    --header='Content-Type: application/json' \
                    'http://rode-collector-build.'"$RODE_NAMESPACE"'.svc.cluster.local:8082/v1alpha1/builds'
                    '''
                }
            }
        }

        stage('Update Deploy Repo') {
            when { branch 'main' }
            steps {
                 container('git') {
					 withCredentials([string(credentialsId: 'github-deploy-pat', variable: 'GITHUB_PAT')]) {
						sh "apk add curl"
						sh "apk add jq"
						script {
							imagesha=sh(script: "echo \"$image\" | tr -d '[:space:]' | sed 's/sha256://g'", returnStdout: true).trim()
						}
						sh "IMAGE_TAG=$imagesha ./deploy-dev.sh"
					}
                }
            }
        }
    }
}
