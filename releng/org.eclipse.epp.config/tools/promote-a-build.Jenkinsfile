// Based on https://wiki.eclipse.org/Jenkins#Pipeline_job_without_custom_pod_template
pipeline {
  agent any
  parameters {
    booleanParam(defaultValue: true, description: 'Do a dry run of the build. Everything will be done except the final copy to download which will be echoed', name: 'DRY_RUN')
    string(defaultValue: '2020-12', description: 'The release name. Release is uploaded to https://download.eclipse.org/technology/epp/downloads/release/RELEASE_NAME', name: 'RELEASE_NAME')
    string(defaultValue: 'M1', description: 'The name of the milestone, e.g. M1, M2, M3, RC1 or R', name: 'RELEASE_MILESTONE')
    string(defaultValue: '202009101200', description: 'The name of the directory to place the release, generally the timestamp', name: 'RELEASE_DIR')
  }
  options {
    timestamps()
    disableConcurrentBuilds()
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
