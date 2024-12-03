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
    stage('Finalize Release') {
      steps {
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
         sh './releng/org.eclipse.epp.config/tools/finalize-release.sh'
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
