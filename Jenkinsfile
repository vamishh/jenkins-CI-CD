def getDockerTag() {
    return sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
}

pipeline {
    agent {
        docker {
            image 'maven:3-openjdk-11'
        }
    }
    environment {
        Docker_tag = getDockerTag()
        PATH = "/usr/bin:$PATH"
    }
    stages {
        stage('Quality Gate Status Check') {
            steps {
                script {
                    withSonarQubeEnv('sonarserver') { 
                        sh "mvn clean sonar:sonar"
                    }
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                    sh "mvn clean install"
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh 'docker build . -t vamish/jenkins:$Docker_tag'
                    withCredentials([string(credentialsId: 'token', variable: 'docker_password')]) {
                        sh '''
                            docker login -u vamish -p $docker_password
                            docker push vamish/jenkins:$Docker_tag
                        '''
                    }
                }
            }
        }
    }
}
