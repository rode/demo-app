def tag = ""
def image = ""
pipeline {
    agent {
        kubernetes {
            yamlFile "jenkins-agent.yaml"
        }
    }

    stages {
        stage('Scan') {
            steps {
                container('sonarqube') {
                    withSonarQubeEnv('SonarQube') {
                        sh '/usr/bin/entrypoint.sh -Dsonar.projectKey="rode:demo-app" -Dsonar.analysis.resourceUriPrefix=github.com/rode/demo-app'
                    }
                }
            }
        }
        stage('Build') {
            steps {
                container('git') {
                    script {
                        sh(script: "date -u +'%Y-%m-%dT%H:%M:%SZ' > build-start", returnStdout: true).trim()
                        tag = sh(script: 'git rev-parse --short HEAD > image-tag && echo "$GIT_BRANCH-`cat image-tag`"', returnStdout: true).trim()
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
                    buildStart=$(cat build-start)
                    buildEnd=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
                    imagesha=$(cat image | tr -d '[:space:]')
                    tag=$(cat image-tag)
                    commit=$(git rev-parse HEAD)
                    creator=$(git show -s --format='%ae')
                    repository="https://github.com/rode/demo-app"

                    wget -O- \
                    --post-data='{
                        "repository": "'$repository'",
                        "artifacts": [
                            {
                                "id": "'$HARBOR_HOST'/rode-demo/rode-demo-node-app@'$imagesha'",
                                "names": [
                                    "'$HARBOR_HOST'/rode-demo/rode-demo-node-app:'$tag'"
                                ]
                            }
                        ],
                        "buildStart": "'$buildStart'",
                        "buildEnd": "'$buildEnd'",
                        "provenanceId": "'$BUILD_URL'",
                        "logsUri": "'$BUILD_URL'consoleText",
                        "creator": "'$creator'",
                        "commitId": "'$commit'",
                        "commitUri": "'$repository'/commit/'$commit'"
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
