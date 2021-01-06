#!/bin/bash

## -- Help Context
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-p] ]
    -m [manifest]      Manifest Name
    -p [preset]        Preset Name
    -k [parentkey]     Custom Parent Key
    -P [keypath]       Custom Key Path
    -a [helm args]     Additional Helm Arguments
    -M                 Minimal Structure
    -h                 Show this context

EOF
}

## -- Defaults
MANIFEST=""
PRESET=""
HELM_ARGS=""
KEYPATH=""
MINIMAL=""
PARENTKEY=""

## -- Opting arguments
OPTIND=1; # Reset OPTIND, to clear getopts when used in a prior script
while getopts ":ha:P:k:m:p:k:M" opt; do
  case ${opt} in
    m)
       MANIFEST="${OPTARG}"
       ;;
    p)
       PRESET="${OPTARG}"
       ;;
    k)
       PARENTKEY="${OPTARG}"
       ;;
    P)
       KEYPATH="${OPTARG}"
       ;;
    a)
       HELM_ARGS="${OPTARG}"
       ;;
    M)
       MINIMAL="true"
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

## -- Helm Values
HELM_VALUES=""
[ -n "$MANIFEST" ] && HELM_VALUES="--set doc.manifest=${MANIFEST}"
[ -n "$PRESET" ] && HELM_VALUES="${HELM_VALUES} --set doc.preset=${PRESET}"
[ -n "$KEYPATH" ] && HELM_VALUES="${HELM_VALUES} --set doc.path=${KEYPATH}"
[ -n "$PARENTKEY" ] && HELM_VALUES="${HELM_VALUES} --set doc.key=${PARENTKEY}"
[ -n "$MINIMAL" ] && HELM_VALUES="${HELM_VALUES} --set doc.minimal=true"

## -- Execute Helm
$HELM_BIN template $HELM_VALUES ${HELM_ARGS} --dependency-update $HELM_PLUGIN_DIR/values-generator/
