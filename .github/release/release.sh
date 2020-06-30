#!/usr/bin/env bash
# Copyright The Bedag Informatik AG Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -o errexit

## -- Help Context
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-c config] [-t token] [-d charts] [-r repo_name] [-l repo_url] [-u g_user] [-e g_email]

    -h            Display this help and exit

    -c config     Define a custom chart-releaser configuration
                    Default: \$HOME/.cr.yaml
                    Environment Variable: `\$CR_CONFIG_LOCATION`

    -t token      Define the github token used.
                    Environment Variable: `\$CR_TOKEN`
                    Required

    -d charts     Define one or multiple chart directories. Multiple chart directories are declared as comma separeted list (eg. stable/, incubator/)
                    Default: charts/

    -r repo_name  Define the name of the repository (For releases)
                    Default: \$(cut -d '/' -f 2 <<< \$GITHUB_REPOSITORY)
                    Environment Variable: `\$CR_REPO_NAME`
                    Required

    -l repo_url   Define the url where the charts are being published. This is used to merge the index.yaml, so the value should be the link the index.yaml is found (without index.yaml)
                    Environment Variable: `\$CR_REPO_URL`
                    Default: https://\$(cut -d '/' -f 1 <<< \$GITHUB_REPOSITORY).github.io/helm-charts/
                    Required

    -u g_user     Define the username for the git user
                    Default: \$GITHUB_ACTOR
                    Environment Variable: `\$GIT_USERNAME`

    -e g_email    Define the email adress for the git user
                    Default: \$GITHUB_ACTOR@users.noreply.github.com
                    Environment Variable: `\$GIT_EMAIL`

EOF
}


## -- Opting arguments
OPTIND=1; # Reset OPTIND, to clear getopts when used in a prior script
while getopts ":hc:t:r:n:u:e:d:" opt; do
  case ${opt} in
    c)
       CR_CONFIG_LOCATION="${OPTARG}";
       ;;
    t)
       CR_TOKEN="${OPTARG}";
       ;;
    d)
       CHART_ROOT="${OPTARG}";
       ;;
    r)
       CR_REPO_NAME="${OPTARG}";
       ;;
    l)
       CR_REPO_URL="${OPTARG}";
       ;;
    u)
       GIT_USERNAME="${OPTARG}";
       ;;
    e)
       GIT_EMAIL="${OPTARG}";
       ;;
    h)
       show_help
       exit 0
       ;;
    ?)
       echo "Invalid Option: -$OPTARG" 1>&2
       exit 1
       ;;
  esac
done
shift $((OPTIND -1))

#
## Function: requiredEnvs()
# Checks if required Environment variables
# are defined or set defaults.
requiredEnvs() {

  # CR Configuration Variables (Required)
  CR_TOKEN="${CR_TOKEN:?Missing required Variable (or use -t)}";
  CR_REPO_URL="${CR_REPO_URL:-https://$(cut -d '/' -f 1 <<< $GITHUB_REPOSITORY).github.io/helm-charts/}";
  CR_REPO_URL="${CR_REPO_URL:?Missing required Variable (or use -l)}";
  CR_REPO_NAME="${CR_REPO_NAME:-$(cut -d '/' -f 2 <<< $GITHUB_REPOSITORY)}";
  CR_REPO_NAME="${CR_REPO_NAME:?Missing required Variable (or use -r)}";

  # CR Locations / Charts Root Directories
  CHART_ROOT="${CHART_ROOT:-charts/}"
  CR_CONFIG_LOCATION="${CR_CONFIG_LOCATION:-$HOME/.cr.yaml}"
  CR_RELEASE_LOCATION="${CR_RELEASE_LOCATION:-.cr-release-packages}"

  # CR Config Check
  [ -f "${CR_CONFIG_LOCATION}" ] && CR_ARGS="--config \"${CR_CONFIG_LOCATION}\"";

  # Git Information
  GIT_USERNAME="${GIT_USERNAME:-$GITHUB_ACTOR}"
  GIT_USERNAME="${GIT_USERNAME:?Missing required Variable (or use -t)}";
  GIT_EMAIL="${GIT_EMAIL:-$GITHUB_ACTOR@users.noreply.github.com}"
  GIT_EMAIL="${GIT_EMAIL:?Missing required Variable (or use -t)}";
}

#
## Function: prepareDirs()
# Outputs changed Chart.yaml files in the
# chart root directory
prepareDirs() {
  rm -rf ${CR_RELEASE_LOCATION} && mkdir -p ${CR_RELEASE_LOCATION} ## Recreates Package Directory
  rm -rf .cr-index && mkdir -p .cr-index ## Recreates Index File
}

#
## Function: crRelease
# Creates a github release for a specific package
crRelease() {
    cr upload -o "$GIT_USERNAME" -r "$CR_REPO_NAME" $CR_ARGS
}

#
## Function: crPackage(chart_name)
# Creates a helm package for the given name
crPackage() {
    helm package $1 --destination ${CR_RELEASE_LOCATION} --dependency-update
}

#
## Function: crIndex()
# Updates Package Index and pushes it
# to gh-pages branch
crIndex() {

    # Setup Git
    git config user.name "$GIT_USERNAME"
    git config user.email "$GIT_EMAIL"

    # Recreate Index
    cr index -o "$GIT_USERNAME" -r "$CR_REPO_NAME" -c "$CR_REPO_URL" $CR_ARGS

    # Push updated Index
    git checkout -f gh-pages
    cp -f .cr-index/index.yaml index.yaml || true
    git add index.yaml
    git status
    git commit -sm "Update index.yaml"
    git push origin gh-pages
}

## Function: latestTag()
# returns latest git tag
latestTag() {
    if ! git describe --tags --abbrev=0 2> /dev/null; then git rev-list --max-parents=0 --first-parent HEAD; fi
}

## Function: tagValidation()
# Checks latest tags. Looks for Changes
tagValidation() {

  # Fetch git tags
  git fetch --tags
  HEAD_REV=$(git rev-parse --verify HEAD);
  LATEST_TAG_REV=$(git rev-parse --verify "$(latestTag)");

  # Check If head differs from latest tag
  if [[ "$LATEST_TAG_REV" == "$HEAD_REV" ]]; then echo "Nothing to do!" && exit 0; fi
}

## Function: release()
# Iterates over changed charts and creates
# a release. If no changed chart is found
# no action will be made
release() {

  ## Check required environment variables
  requiredEnvs

  # Validation of git tags
  tagValidation

  # Evaluate chart root directories
  if [[ ${CHART_ROOT} == *","* ]]; then
    IFS=', ' read -r -a ROOT_DIRS <<< "${CHART_ROOT}"
  else
    ROOT_DIRS=(${CHART_ROOT})
  fi

  # Find changes for each chart in each directory
  local CHANGED_CHARTS=""
  for i in "${ROOT_DIRS[@]}"
  do
    # For each root directory, check for changes to Chart.yaml
    local CHART_INDICATOR="$( echo ${i%/} | tr -d '[:space:]' )/*/Chart.yaml"
    CHANGED_CHARTS="${CHANGED_CHARTS} $(git diff --find-renames --name-only $LATEST_TAG_REV -- $CHART_INDICATOR | cut -d '/' -f 1-2 | uniq)"
  done

  # Return all elements (xargs is used to trim spaces)
  readarray -t PUBLISH_CHARTS <<< "$(echo ${CHANGED_CHARTS} | xargs )"

  # Iteration over Charts
  if ! [[ -z $(echo "${CHANGED_CHARTS}" | xargs) ]] && [[ ${#PUBLISH_CHARTS[@]} -gt 0 ]]; then

      # Check for each chart, if the directory exists
      # this serves as handler, when chart directories are deleted
      EXISTING_CHARTS=()
      for preChart in "${PUBLISH_CHARTS[@]}"; do
          local trimChart="$(echo $preChart | xargs)"
          [ -d "$trimChart" ] && EXISTING_CHARTS+=($trimChart)
      done

      if [[ ${#EXISTING_CHARTS[@]} -gt 0 ]]; then

          # Recreate required directories
          prepareDirs

          # Create Package for each chart
          echo -e "\n\e[33m- Crafting Packages\e[0m"
          for chart in "${EXISTING_CHARTS[@]}"; do
              echo -e "\n\e[32m-- Package: $chart\e[0m"
              crPackage "$chart" ## Create Helm Package
          done

          # Release all packaged charts
          echo -e "\n\e[33m- Creating Releases\e[0m\n"
          crRelease

          # Update repository Index
          echo -e "\n\e[33m- Creating Index\e[0m\n"
          crIndex
      else
          # Feedback
          echo -e "\n\e[33mChanges to non existent chart detected.\e[0m\n"; exit 0;
      fi
  else
      # Feedback
      echo -e "\n\e[33mNo Changes on any chart detected.\e[0m\n"; exit 0;
  fi
}
release
