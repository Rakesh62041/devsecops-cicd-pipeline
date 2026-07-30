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

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
                        export PATH=/opt/maven/bin:$JAVA_HOME/bin:$PATH

                        /opt/maven/bin/mvn sonar:sonar \
                        -Dsonar.projectKey=devsecops-cicd-pipeline \
                        -Dsonar.projectName=devsecops-cicd-pipeline
                    '''
                }
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
