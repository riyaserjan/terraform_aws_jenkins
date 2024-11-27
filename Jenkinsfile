pipeline {
    agent any
    stages {
        stage('Checkout From Git') {
            steps {
                git branch: 'main',  url: 'https://github.com/riyaserjan/terraform_aws_jenkins.git'
            }
        }
        stage('Terraform version') {
            steps {
                sh 'terraform version'
            }
        }
    }
}
