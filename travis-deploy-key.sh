#!/bin/bash -e
#
# This is a script to add a secret key to Travis CI

usage_exit() {
  echo ""
  echo "  Usage:"
  echo "    travis-deploy-key [-r owner/repo] [user@]hostname"
  echo ""
  exit 0
}

echo_bold() {
  echo -e "\033[1m${1}\033[0m"
}

# 引数解析

while getopts hr: OPT
do
  case $OPT in
    h)  usage_exit ;;
    r)  repo_option="-r $OPTARG" ;;
    \?) usage_exit ;;
  esac
done

shift $(($OPTIND - 1))

user_hostname=$1
repository_name=$(basename -s .git $(git config --get remote.origin.url))

if [ -z "$user_hostname" ]
then
  usage_exit
fi

# ツールチェック

if ! [ `which travis` ]
then
  echo ""
  echo "  Not found \"travis\" command."
  echo "  Check out https://github.com/travis-ci/travis.rb#installation to install."
  echo ""
  exit 1
fi

if ! [ `travis whoami` ]
then
  # `travis whoami` shows error message.
  exit 1
fi

# メイン

echo_bold "Check SSH login..."

ssh $user_hostname :

echo_bold "...Done"
echo_bold ""

echo_bold "Genarating deploy key..."

ssh-keygen -t rsa -b 4096 -C "${repository_name}@travis-ci" -f deploy_rsa -N ""

echo_bold "...Done"
echo_bold ""

echo_bold "Add deploy key to Travis..."

# -r オプションを与えていればここで渡される
travis encrypt-file deploy_rsa --add $repo_option || ( rm -f deploy_rsa deploy_rsa.pub; exit 1 )

echo_bold "...Done"
echo_bold ""

echo_bold "Copy public key to ssh host..."

ssh-copy-id -f -i deploy_rsa.pub $user_hostname

echo_bold "Done"
echo_bold ""

rm -f deploy_rsa deploy_rsa.pub

echo_bold ""
echo_bold "  [SUCCESS]"
echo_bold "  Encrypted deploy key is generated."
echo_bold "  Please git add \"deploy_rsa.enc\" file."
echo_bold ""
