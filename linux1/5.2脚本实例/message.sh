#!/bin/bash

script_dir=$( cd  $(dirname "$0") && pwd)
curl -X POST "https://api.telegram.org/bot837606463:AAH_XczVvmVPsL35tbw8z96DimSYijGnnCI/sendMessage" -d "chat_id=-368314263&text=`cat ${script_dir}/确定有问题状态码.txt
`"
rm -rf ${script_dir}/china无问题状态码.txt
rm -rf ${script_dir}/可能存在问题状态码.txt
rm -rf ${script_dir}/正确状态码.txt 
rm -rf ${script_dir}/确定有问题状态码.txt
