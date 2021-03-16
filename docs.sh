## Constants  
. colors.sh
HAS_ERROR=0
DOC_CHARTS=()

## Create Documentation Checksum
echo -e "${Yellow}Creating Checksums${Off}" 
for chart in ${CHANGED_CHARTS}; do
  if [ -f "${chart%/}/README.md" ]; then 
    DOC_CHARTS+=(${chart})
    shasum ${chart%/}/README.md > ${chart%/}/README.md.sum
    echo -e "[${chart}]: ${Green}Checksum created ($(cat ${chart%/}/README.md.sum))${Off}" 
  else 
    echo -e "[${chart}]: ${Yellow}No README.md file detected${Off}"  
  fi   
done 

## Execute helm-docs
echo -e "\n${Yellow}Executing Helm-Docs${Off}"
helm-docs > /dev/null

## Check Checksums 
echo -e "\n${Yellow}Validating Checksums${Off}" 
for chart in ${DOC_CHARTS[@]}; do
  if [[ $(shasum "${chart%/}/README.md") == $(cat "${chart%/}/README.md.sum") ]]; then 
    echo -e "[${chart}]: ${Green}Documentation up to date${Off}"
  else
    HAS_ERROR=1;
    echo -e "[${chart}]: ${Red}Checksums did not match - Documentation outdated!${Off}"
  fi   
done 

## Exit
echo ""
if [ $HAS_ERROR -ne 0 ]; then
  echo -e "${Red}Errors detected${Off}" 
  exit 1
else 
  echo -e "${Green}No Errors detected${Off}"
  exit 0;
fi