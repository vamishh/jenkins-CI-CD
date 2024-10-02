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
        PATH = "/usr/local/bin:${env.PATH}" // Assuming Docker is installed at /usr/local/bin/docker
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

        stage('Ansible Playbook') {
            steps {
                script {
                    sh '''
                        final_tag=$(echo $Docker_tag | tr -d ' ')
                        echo ${final_tag}test
                        sed -i "s/docker_tag/$final_tag/g" deployment.yaml
                    '''
                    ansiblePlaybook become: true, installation: 'ansible', inventory: 'hosts', playbook: 'ansible.yaml'
                }
            }
        }
    }
}

