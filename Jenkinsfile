pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Rakesh62041/devsecops-cicd-pipeline.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
                    export PATH=/opt/maven/bin:$JAVA_HOME/bin:$PATH

                    java -version
                    /opt/maven/bin/mvn -version
                    /opt/maven/bin/mvn clean package -DskipTests
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Deploy') {
    steps {
        sh '''
            docker compose down --remove-orphans || true
            docker compose up -d
        '''
    }
}
        

        stage('Verify') {
            steps {
                sh 'docker compose ps'
            }
        }
    }
}
