# gitlab-ci-android-fastlane
Docker image for Gitlab CI runner; includes Android SDK and Fastlane installation.
Based on [jangrewe's gitlab-ci-android](https://hub.docker.com/r/jangrewe/gitlab-ci-android/) with [Fastalne tools](https://fastlane.tools/) installation
## Usage:
`.gitlab-ci.yml` example:
```
image: atorubar/gitlab-ci-android-fastlane

stages:
- build
- test
- deploy

before_script:
  - export GRADLE_USER_HOME=$(pwd)/.gradle
  - chmod +x ./gradlew

######################### BUILD ##############################
.build_template: &build
  stage: build

build:debug:
  <<: *build
  only:
    - master
  script:
    - ./gradlew assembleDebug
  cache:
    key: ${CI_PROJECT_ID}
    paths:
      - .gradle/wrapper/
      - .gradle/caches/
    policy: push

######################### TEST ##############################
.test_template: &test
  stage: test
  only:
    - master
  cache:
    key: ${CI_PROJECT_ID}
    paths:
      - .gradle/wrapper/
      - .gradle/caches/
    policy: pull

test:unit:
  <<: *test
  script:
    - ./gradlew test
  artifacts:
    name: "reports_${CI_PROJECT_NAME}_${CI_BUILD_REF_NAME}"
    when: on_failure
    expire_in: 3 days
    paths:
      - app/build/reports/tests/
      
######################### DEPLOY ##############################
deploy_alpha:
  stage: deploy
  script:
    - fastlane alpha
  artifacts:
    paths:
      - fastlane/report.xml
    expire_in: 8 hours
  when: manual
```

`Fastfile` example (builds signed APK and submits alpha release into HockeyApp):
```
default_platform(:android)

platform :android do

  desc "Submit a new Alpha Build to Hockey App"
  lane :alpha do
    gradle(task: "clean assembleSignedDebug",
    properties: {
        "versionCode" => ENV["CI_PIPELINE_IID"].to_i
      })
    date = Time.now.strftime('%F')
    time = Time.now.strftime('%T')
    build_number =  ENV["CI_BUILD_REF_NAME"] ? "Build " + ENV["CI_BUILD_REF_NAME"] : ""
    branch_name =  ENV["CI_COMMIT_REF_NAME"] ? "Build " + ENV["CI_COMMIT_REF_NAME"] : ""
    commit =  ENV["CI_COMMIT_MESSAGE"] ? "Build " + ENV["CI_COMMIT_MESSAGE"] : ""
    hockey(
          public_identifier: ENV["HOCKEYAPP_APP_ID"],
          apk: "app/build/outputs/apk/signedDebug/app-signedDebug.apk",
          api_token: ENV["HOCKEY_APP_API_TOKEN"],
          notify: "1",
          release_type: "2",
          notes: "#{build_number} Last commit: #{commit} from #{branch_name} branch on #{date} at #{time}",
          commit_sha: ENV["CI_COMMIT_SHA"]
        )
  end
end

```
