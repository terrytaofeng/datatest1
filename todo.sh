#!/bin/bash


ROOT=`dirname $0`
ROOT=`(cd $ROOT;pwd)`

function get_remoter_ip(){
  wget --timeout=5 -qO- http://ipecho.net/plain
}


#function  key
function encrypt_data(){
  [ "x$1" == "x" ] && return;
  openssl enc -e -base64 -aes-128-ctr -nopad -nosalt -k $1
}

#function  key
function decrypt_data(){
  [ "x$1" == "x" ] && return;
  openssl enc -d -base64 -aes-128-ctr -nopad -nosalt -k $1
}



REMOTE_FILE="remote_ip"
DEMO="demo.md"
#function key
function update_ip_file(){

  [ "x$1" == "x" ] && return;

  local key=$1


  pushd $ROOT

  git pull
  git push 
  local org;
  [ -f $REMOTE_FILE ] && org=`cat $REMOTE_FILE|decrypt_data $key`

  local cur=`get_remoter_ip`
  [ "x$cur" == "x" ] && return;

  if [ "x$org" != "x$cur" ]; then
    echo $cur | encrypt_data $key > $REMOTE_FILE
    git add $REMOTE_FILE
    git commit -m 'update'
    git push
  fi

  popd

}

function update_demo_file(){
  local cur=`get_remoter_ip`
  local org;
  [ "x$cur" == "x" ] && return;


  pushd $ROOT

  if git status --porcelain|grep ^M;then
      git pull
      git commit -m 'update'
      git push
  fi


  [ -f $REMOTE_FILE ] && org=`cat $REMOTE_FILE`
  [ "x$org" == "x$cur" ] && return;


  git pull

  [ -f $REMOTE_FILE ] && org=`cat $REMOTE_FILE`
  if [ "x$org" != "x$cur" ]; then
    echo $cur > $REMOTE_FILE
    {
  cat<<EOF
Here's a link to [demo](http://$cur),
EOF
    } > $DEMO
    git add $REMOTE_FILE $DEMO
    git commit -m 'update'
    git push
  fi




  popd


}

#======================================================================================
#bash process system
#======================================================================================
for bbb in ./ /usr/bin;do
    if [ -f $bbb/bps.inc ];then
	source $bbb/bps.inc $*
	break;
    fi
done



