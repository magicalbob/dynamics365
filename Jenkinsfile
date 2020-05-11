pipeline {
  agent {
    label 't7610'
  }

  stages {
    stage('terraform apply dynamics') {
      steps {
        script {
          sh """
            ./scripts/build-terraform.sh
          """
        }
      }
    }

    stage('test build status') {
      steps {
        script {
          sh """
            ./scripts/test-build.sh
          """
        }
      }
    }

    stage('test new org created') {
      steps {
        script {
          sh """
          """
          try {
              sh './scripts/test-org.sh'
          }
          catch (exc) {
              echo 'Creating org failed!'
              currentBuild.result = 'UNSTABLE'
          }
        }
      }
    }
  }
}
