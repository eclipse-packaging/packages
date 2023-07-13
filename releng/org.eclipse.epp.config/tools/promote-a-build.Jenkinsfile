// Based on https://wiki.eclipse.org/Jenkins#Pipeline_job_without_custom_pod_template
pipeline {
  agent any
  parameters {
    booleanParam(defaultValue: true, description: 'Do a dry run of the build. Everything will be done except the final copy to download which will be echoed', name: 'DRY_RUN')
  }
  options {
    timestamps()
    disableConcurrentBuilds()
  }
  tools {
    maven 'apache-maven-latest'
    jdk 'temurin-jdk17-latest'
  }
  stages {
    stage('Upload') {
      steps {
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
         sh './releng/org.eclipse.epp.config/tools/promote-a-build.sh'
        }
      }
    }
  }
  post {
    cleanup {
      cleanWs()
    }
  }
}
