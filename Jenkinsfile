pipeline {
  agent any
  stages {
    stage('Deploy to S3') {
      steps {
        git url:'https://github.com/KaterynaPugach/lab1.git', branch: "main"
        sh "aws s3 cp index.html s3://puhach-s3-bucket"
      }
    }
  }
}
