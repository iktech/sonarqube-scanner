version = "4.8.0.2856"
namespace = "jenkins"
repositoryServer = "docker-registry-publish.iktech.io"
projectName = "sonarqube-scanner"
image = "${repositoryServer}/${namespace}/${projectName}"
def dockerImage

podTemplate(label: 'buildkit-pod', cloud: 'kubernetes', serviceAccount: 'jenkins',
  containers: [
    containerTemplate(name: 'buildkit', image: 'moby/buildkit:master', ttyEnabled: true, privileged: true),
  ],
  volumes: [
    secretVolume(mountPath: '/etc/.ssh', secretName: 'ssh-home'),
    secretVolume(mountPath: '/tmp/docker', secretName: 'docker-config'),
  ]
) {
    node('gopod') {
        stage('Prepare') {
            sh '''
				mkdir -p ~/.ssh
				chmod 700 ~/.ssh
            	ssh-keyscan -H github.com > ~/.ssh/known_hosts
            	cat /etc/.ssh/id_rsa > ~/.ssh/id_rsa
            	chmod 400 ~/.ssh/id_rsa
            '''
            checkout scm
            tag="${env.BRANCH_NAME}-${version}-${env.BUILD_NUMBER}"
        }

		container('buildkit') {
			stage('Build Docker Image') {
				try {
					sh """
						mkdir -p /root/.docker
						cp /tmp/docker/config.json /root/.docker/

						wget https://raw.githubusercontent.com/anchore/grype/main/install.sh
						chmod 755 install.sh

						./install.sh
						mv bin/grype /usr/local/bin/

						buildctl build \
		           			--progress plain \
							--frontend dockerfile.v0 \
							--local context=. \
							--local dockerfile=. \
							--export-cache type=local,dest=/tmp/buildkit/cache \
							--output type=oci,dest=/tmp/image.tar \
							--opt network=host \
							--opt build-arg:SONARQUBE_SCANNER_VERSION=${version}
					"""
					milestone()
				} catch (error) {
					slackSend color: "danger", message: "Publishing Failed - ${env.JOB_NAME} build number ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
					throw error
				}
			}

			stage('Scan Docker Image') {
				try {
					sh """
						wget https://iktech-public-dl.s3.eu-west-1.amazonaws.com/grype/grype.tmpl
						GRYPE_MATCH_GOLANG_USING_CPES=false /usr/local/bin/grype oci-archive:/tmp/image.tar -f high --scope all-layers -o template --file report.html -t grype.tmpl
						ls -l
					"""
				} catch (error) {
					slackSend color: "danger", message: "Grype scan has failed - ${env.JOB_NAME} build number ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
					throw error
				} finally {
					publishHTML (target : [allowMissing: false,
                     alwaysLinkToLastBuild: true,
                     reportDir: '',
                     keepAll: true,
                     reportFiles: 'report.html',
                     reportName: 'Grype Scan Report',
                     reportTitles: 'Grype Scan Report'])
				}
				milestone()
			}
		}

        container('buildkit') {
            stage('Push Docker Image to the container registry') {
                try {
                    sh """
                        buildctl build \
                            --progress plain \
                            --frontend dockerfile.v0 \
                            --local context=. \
                            --local dockerfile=. \
                            --export-cache type=local,dest=/tmp/buildkit/cache \
                            --import-cache type=local,src=/tmp/buildkit/cache \
                            --output type=image,name=${image},push=true \
                            --opt network=host \
							--opt build-arg:SONARQUBE_SCANNER_VERSION=${version}
                        """
                    milestone()
                } catch (error) {
                    slackSend color: "danger", message: "Publishing Failed - ${env.JOB_NAME} build number ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    throw error
                }
            }
        }
	}
}

properties([[
    $class: 'BuildDiscarderProperty',
    strategy: [
        $class: 'LogRotator',
        artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10']
    ]
]);

