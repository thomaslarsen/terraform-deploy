#!/bin/bash

DIR_PHASE=$(git rev-parse --show-prefix | cut -d'/' -f1)
DIR_OBJECT=$(git rev-parse --show-prefix | cut -d'/' -f2)

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c=*|--class=*)
    CLASS="${1#*=}"
    shift # past argument
    ;;
    -n=*|--name=*)
    VAR_SETTINGS0="-var vdc_name=${1#*=}"
    TARGET_NAME="${1#*=}"
    VDC_NAME="${1#*=}"
    shift # past argument
    ;;
    -d=*|--vdc=*)
    VAR_SETTINGS1="-var vdc_name=${1#*=}"
    VDC_NAME="${1#*=}"
    shift # past argument
    ;;
    -zi=*|--zone-index=*)
    VAR_SETTINGS2="-var appzone_index=${1#*=}"
    APPZONE_NAME="${1#*=}"
    shift # past argument
    ;;
    -vi=*|--vdc-index=*)
    VAR_SETTINGS3="-var vdc_index=${1#*=}"
    VDC_INDEX="${1#*=}"
    shift # past argument
    ;;
    -h|--help)
    echo "Usage:"
    echo "${0#*/} [options] command [parameters]"
    echo "Options:"
    echo "-c --class=the deployment class, e.g. dev, test, prod"
    echo "-n --name=name of VDC or zone"
    echo "-d --vdc=VDC name (default dc0)"
    echo "-zi --zone-index=Application Zone index (default 0)"
    echo "-vi --vdc-index=VDC index (default 0)"
    echo "-h --help This message"
    exit 1
    ;;
    -*|--*)
    echo Unknown option $1
    exit 1
    ;;
    *)
    break
    ;;
esac
done

echo DIR Phase: $DIR_PHASE
echo DIR Object: $DIR_OBJECT
echo
echo 1=$1
echo 2=$2
echo 3=$3
echo 4=$4

if [ "$DIR_PHASE" != "vdcs" ] && [ "$DIR_PHASE" != "zones" ]; then
  # We are not in the directory tree of VDCs or App Zones
  TF_PHASE=$1
  TF_OBJECT=$2
  shift
  shift
else
  # We are in the directory tree of VDCs or App Zones
  if [ "$1" == "vdcs" ] || [ "$1" == "zones" ]; then
    # The first parameter is overriding whatever dir we are in
    TF_PHASE=$1
    # The object must also be given
    TF_OBJECT=$2
    shift
    shift
  elif [ "$DIR_OBJECT" == "" ]; then
    # We are in the dir tree and the parameter is the same as the object
    TF_PHASE=$DIR_PHASE
    TF_OBJECT=$1
    shift
  else
    TF_PHASE=$DIR_PHASE
    TF_OBJECT=$DIR_OBJECT
  fi
fi

COMMAND=$@

# If we have not specified a target name using the -n parameter, use the object name
if [ "$TARGET_NAME" == "" ]; then
  TF_NAME=$TF_OBJECT
else
  TF_NAME=$TARGET_NAME
fi

TF_CLASS=${CLASS:-dev}

export AWS_SHARED_CREDENTIALS_FILE=$(git rev-parse --show-toplevel)/.aws/credentials

if [ ! -e "$(git rev-parse --show-toplevel)/$TF_PHASE/$TF_OBJECT" ]; then
  echo Unknown $TF_PHASE/$TF_OBJECT
  exit 1
fi

if [ "$COMMAND" == "plan" ] || [ "$COMMAND" == "apply" ] || [ "$COMMAND" == "refresh" ]; then
  TF_VAR_FILE="-var-file=$(git rev-parse --show-toplevel)/config/$TF_PHASE.$TF_NAME.json"
  TF_STATE_FILE="-state=$(git rev-parse --show-toplevel)/state/$TF_NAME.$TF_PHASE.tfstate"
  case $TF_PHASE in
    zones)
      TF_VAR_SETTINGS="$VAR_SETTINGS1 $VAR_SETTINGS2"
      # If class setting file exist, add it
      if [ -f "$(git rev-parse --show-toplevel)/config/$TF_PHASE.$TF_NAME.$TF_CLASS.json" ]; then
        TF_VAR_FILE="$TF_VAR_FILE -var-file=$(git rev-parse --show-toplevel)/config/$TF_PHASE.$TF_NAME.$TF_CLASS.json"
      fi
      ;;
    vdcs)
      TF_VAR_SETTINGS="$VAR_SETTINGS0 $VAR_SETTINGS3"
      ;;
  esac
fi

echo VDC index:     $VDC_INDEX
echo VPC name:      $VPC_NAME
echo AppZone index: $APPZONE_INDEX
echo Target Name:   $TF_NAME
echo Class:         $TF_CLASS

echo
echo Phase:         $TF_PHASE
echo Object:        $TF_OBJECT
echo

echo VAR File:      $TF_VAR_FILE
echo VAR Settings:  $TF_VAR_SETTINGS
echo STATE File:    $TF_STATE_FILE
echo DIR:           $(git rev-parse --show-toplevel)/$TF_PHASE/$TF_OBJECT

echo Command:       $@

echo
 terraform $@ $TF_STATE_FILE $TF_VAR_FILE $TF_VAR_SETTINGS $(git rev-parse --show-toplevel)/$TF_PHASE/$TF_OBJECT
