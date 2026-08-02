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

        stage('OWASP Dependency Check') {
            environment {
                NVD_API_KEY = credentials('nvd-api-key')
            }

            steps {
                sh 'mkdir -p dependency-check-report'

                dependencyCheck(
                    additionalArguments: '''
                        --scan .
                        --format HTML
                        --format XML
                        --out dependency-check-report
                        --nvdApiKey $NVD_API_KEY
                    ''',
                    odcInstallation: 'OWASP-Dependency-Check'
                )
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([
                        string(
                            credentialsId: 'sonarqube-token',
                            variable: 'SONAR_TOKEN'
                        )
                    ]) {
                        sh '''
                            /opt/maven/bin/mvn \
                            org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar \
                            -Dsonar.projectKey=devsecops-cicd-pipeline \
                            -Dsonar.token=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Trivy Image Scan') {
    steps {
        sh '''
            mkdir -p /data/trivy-cache

            docker image inspect \
              devsecops-pipeline-java_app:latest

            trivy image \
              --cache-dir /data/trivy-cache \
              --scanners vuln \
              --severity HIGH,CRITICAL \
              --ignore-unfixed \
              --exit-code 0 \
              devsecops-pipeline-java_app:latest
        '''
    }
}
                stage('Push Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKERHUB_TOKEN" | docker login \
                        -u "$DOCKERHUB_USERNAME" \
                        --password-stdin

                        docker tag \
                        devsecops-cicd-pipeline-java_app:latest \
                        rakeshsharma620/expense-tracker:latest

                        docker push \
                        rakeshsharma620/expense-tracker:latest

                        docker logout
                    '''
                }
            }
        }

       stage('Deploy') {
    steps {
        sh '''
            echo "Stopping old application containers..."

            docker rm -f \
            devsecops-cicd-pipeline-java_app-1 \
            devsecops-cicd-pipeline-mysql_db-1 \
            2>/dev/null || true

            echo "Starting new application containers..."

            docker compose up -d --force-recreate

            echo "Current container status:"
            docker compose ps
        '''
    }
}

        stage('Health Check') {
            steps {
                sh '''
                    echo "Waiting for application to start..."

                    for i in {1..12}; do
                        if curl -fsS http://localhost:8082 > /dev/null; then
                            echo "Application health check passed"
                            exit 0
                        fi

                        echo "Application is not ready yet. Retrying..."
                        sleep 5
                    done

                    echo "Application health check failed"
                    exit 1
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
