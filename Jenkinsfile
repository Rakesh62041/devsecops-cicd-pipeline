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

        dependencyCheck additionalArguments: '''
            --scan .
            --format HTML
            --format XML
            --out dependency-check-report
            --nvdApiKey $NVD_API_KEY
        ''',
        odcInstallation: 'OWASP-Dependency-Check'
    }
}
     stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
                        export PATH=/opt/maven/bin:$JAVA_HOME/bin:$PATH

                        /opt/maven/bin/mvn \
                        org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar \
                        -Dsonar.projectKey=devsecops-cicd-pipeline \
                        -Dsonar.projectName=devsecops-cicd-pipeline
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
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
            trivy image \
              --severity HIGH,CRITICAL \
              --ignore-unfixed \
              --exit-code 0 \
              devsecops-pipeline-java_app:latest
        '''
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
