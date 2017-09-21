pipeline {
    agent {
        docker { image 'embik/jenkins_builder_phoenix:latest' }
    }


    stages {
        stage('Setup') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'gogs_secret', variable: 'GOGS_SECRET')]) {
                        properties([[$class: 'GogsProjectProperty', gogsSecret: "${env.GOGS_SECRET}"]])
                    }
                }
                sh 'mix deps.get --only prod'
                sh 'cp config/prod.secret.exs.sample config/prod.secret.exs'
                withCredentials([string(credentialsId: 'secret_key_base', variable: 'SECRET_KEY_BASE')]) {
                    sh 'sed -i "s|SECRET+KEY+BASE|$SECRET_KEY_BASE|" config/prod.secret.exs'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'cd assets && npm install && node node_modules/brunch/bin/brunch build --production'
                sh 'MIX_ENV=prod mix deps.compile'
                sh 'MIX_ENV=prod mix do phx.digest, compile'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing ...'
            }
        }
        stage('Release') {
            steps {
                sh 'MIX_ENV=prod mix release'
                archive '_build/prod/rel/**/releases/**/*.tar.gz'
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
