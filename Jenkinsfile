pipeline {
  agent {
    label 't7610'
  }

  triggers {
    cron(env.BRANCH_NAME == 'develop' ? 'H H(1-5) * * 1-7' : '')
  }

  stages {

    stage('packer build dynamics vagrant box') {
      steps {
        script {
          sh """
            ./scripts/build-packer.sh
          """
        }
      }
    }

    stage('terraform apply dynamics') {
      steps {
        script {
          sh """
            JENKINS_NODE_COOKIE=dontKillMe BUILD_ID=dontKillMe ./scripts/build-terraform.sh
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
