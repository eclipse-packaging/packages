pipeline {
  agent any
  options {
    timestamps()
    disableConcurrentBuilds()
  }
  tools {
    maven 'apache-maven-latest'
    jdk 'temurin-jdk17-latest'
  }
  environment {
    BUILDING='/home/data/httpd/download.eclipse.org/technology/epp/building/'
    SSHUSER='genie.packaging@projects-storage.eclipse.org'
    MAVEN_OPTS='-XX:MaxRAMPercentage=50.0'
  }
  stages {
    stage('Prepare shared building space on download.e.o') {
      steps {
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "ssh ${SSHUSER} rm -rf ${BUILDING}"
          sh "ssh ${SSHUSER} mkdir -p ${BUILDING}/repository"
        }
      }
    }
    stage('Build p2') {
      steps {
        sh "mvn verify -Depp.p2.all -Depp.product.all --batch-mode --show-version -Dmaven.repo.local=.repository -Declipse.p2.mirrors=false -Peclipse-sign-jar -Pepp.p2.aggregation"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "scp -rpv releng/org.eclipse.epp.config/aggregation/target/repository/final/* ${SSHUSER}:${BUILDING}/repository/"
        }
      }
    }
    // TODO make this a loop/matrix please
    // For now I can't use matrix because that runs all in parallel and I don't want that here (I could if each one was on a separate node though)
    stage('Build committers') {
      steps {
        sh "mvn verify -Pepp.product.committers -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} committers"
        }
      }
    }
    stage('Build cpp') {
      steps {
        sh "mvn verify -Pepp.product.cpp -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} cpp"
        }
      }
    }
    stage('Build embedcpp') {
      steps {
        sh "mvn verify -Pepp.product.embedcpp -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} embedcpp"
        }
      }
    }
    stage('Build dsl') {
      steps {
        sh "mvn verify -Pepp.product.dsl -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} dsl"
        }
      }
    }
    stage('Build java') {
      steps {
        sh "mvn verify -Pepp.product.java -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} java"
        }
      }
    }
    stage('Build jee') {
      steps {
        sh "mvn verify -Pepp.product.jee -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} jee"
        }
      }
    }
    stage('Build modeling') {
      steps {
        sh "mvn verify -Pepp.product.modeling -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} modeling"
        }
      }
    }
    stage('Build php') {
      steps {
        sh "mvn verify -Pepp.product.php -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} php"
        }
      }
    }
    stage('Build rcp') {
      steps {
        sh "mvn verify -Pepp.product.rcp -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} rcp"
        }
      }
    }
    stage('Build scout') {
      steps {
        sh "mvn verify -Pepp.product.scout -Pepp.materialize-products -Depp.p2.repourl=https://download.eclipse.org/technology/epp/building/repository/ --batch-mode --show-version -Dmaven.repo.local=.repository -Dtycho.disableP2Mirrors=true -Peclipse-sign-jar -Peclipse-sign-mac -Peclipse-sign-dmg -Peclipse-sign-windows -Peclipse-package-dmg"
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-building.sh ${BUILDING} scout"
        }
      }
    }
    stage('Upload to staging') {
      steps {
        sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
          sh "./releng/org.eclipse.epp.config/tools/upload-to-staging.sh"
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
