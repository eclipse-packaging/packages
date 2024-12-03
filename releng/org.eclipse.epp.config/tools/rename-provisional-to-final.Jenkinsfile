// Based on https://wiki.eclipse.org/Jenkins#Pipeline_job_without_custom_pod_template
pipeline {
  agent any
  parameters {
    booleanParam(defaultValue: true, description: 'Do a dry run of the operation', name: 'DRY_RUN')
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
    stage('Rename') {
      steps {
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
         sh './releng/org.eclipse.epp.config/tools/rename-provisional-to-final.sh'
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
