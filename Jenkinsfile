pipeline {
  agent {
    kubernetes {
      inheritFrom 'default'
      label 'jenkins-slave'
      defaultContainer 'jnlp'
    //   workspaceVolume dynamicPVC(accessModes: 'ReadWriteOnce', requestsSize: "10Gi")
    }
  }

  environment {
    GIT_TOKEN = credentials('9fa91a5a-7fc6-4efd-8efc-fa6435f04345')
  }

  tools {
    git 'Default'
  }

  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Build App Docker Image') {
      steps {
        sh '''#!/bin/bash -el
          podman build . -t danieltmcc/homepage:${GIT_COMMIT}
        '''
      }
    }

    stage('Upload Docker App Image') {
      steps {
        withCredentials([string(credentialsId: 'c38f463c-2114-46b6-8258-d2ce411eb615', variable: 'DOCKER_PAT')]) {
          sh '''#!/bin/bash -el
            echo "TODO: Push to local Docker registry - currently using Docker Hub"
            podman login -u danieltmcc -p ${DOCKER_PAT}
            podman push danieltmcc/homepage:${GIT_COMMIT}
          '''
        }
      }
    }

    stage('Deploy Container') {
      steps {
        sh '''#!/bin/bash -el
          sed -i "s/latest/${GIT_COMMIT}/g" helm/Deployment.yaml
          kubectl apply -f helm/Deployment.yaml --force --wait --timeout=60s
        '''
      }
    }
  }
  post {
    always {
      script {
        try {
          sh '''#!/bin/bash -el
            podman image rm -f danieltmcc/homepage:${GIT_COMMIT}
          '''
        } catch (Exception e) {
          echo "Failed to remove image: ${e}"
        }

        cleanWs(cleanWhenNotBuilt: true,
          deleteDirs: true,
          disableDeferredWipeout: true,
          notFailBuild: true,
          patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                     [pattern: '.propsfile', type: 'EXCLUDE']])
      }
    }
  }
}