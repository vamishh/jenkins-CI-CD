def getDockerTag() {
    def tag = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
    return tag
}

pipeline {
    agent {
        docker {
            image 'maven:3.8.1-jdk-11' // Use a specific Maven image with JDK 11
            args '-v $HOME/.m2:/root/.m2'
        }
    }
    environment {
        Docker_tag = getDockerTag()
        PATH = "/usr/bin:${env.PATH}" // Ensure /usr/bin is included in the PATH
    }
    
    stages {
        stage('Quality Gate Status Check') {
            steps {
                script {
                    withSonarQubeEnv('sonarserver') { 
                        sh "mvn -e -X sonar:sonar"
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

        stage('build') {
            steps {
                script {
                    sh 'cp -r ../devops-training@2/target .'
                    sh '/usr/bin/docker build . -t vamish/jenkins:$Docker_tag'
                    withCredentials([string(credentialsId: 'token', variable: 'docker_password')]) {
                        sh '''
                            /usr/bin/docker login -u vamish -p $docker_password
                            /usr/bin/docker push vamish/jenkins:$Docker_tag
                        '''
                    }
                }
            }
        }
    }	       	     	         
}
