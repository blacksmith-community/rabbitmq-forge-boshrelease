#!/bin/bash

# BOSH Env Vars
export HOME=${HOME:-/home/vcap}
export JOB_DIR=/var/vcap/jobs/rabbitmq
export RUN_DIR=/var/vcap/sys/run/rabbitmq
export LOG_DIR=/var/vcap/sys/log/rabbitmq
export TMP_DIR=/var/vcap/sys/tmp/rabbitmq
export STORE_DIR=/var/vcap/store/rabbitmq

# RabbitMQ
export RABBITMQ_PLAN="<%= p('rabbitmq.plan') %>"
export RABBITMQ_ADMIN_PASS="<%= p('rabbitmq.admin.pass') %>"
export RABBITMQ_ADMIN_USER="<%= p('rabbitmq.admin.user') %>"
export RABBITMQ_MONITORING_PASS="<%= p('rabbitmq.monitoring.pass') %>"
export RABBITMQ_MONITORING_USER="<%= p('rabbitmq.monitoring.user') %>"
export RABBITMQ_APP_PASS="<%= p('rabbitmq.app.pass') %>"
export RABBITMQ_APP_USER="<%= p('rabbitmq.app.user') %>"
export RABBITMQ_CONFIG_FILE=${JOB_DIR}/config/rabbitmq.conf
export RABBITMQ_LOG_BASE=${LOG_DIR}
export RABBITMQ_MNESIA_BASE=/var/vcap/store/rabbitmq
export RABBITMQ_NODENAME="rabbit@<%= spec.id %>.<%= spec.name %>.<%= p('rabbitmq.network').gsub('.', '') %>.<%= spec.deployment %>.bosh"
export RABBITMQ_PID_FILE="${RUN_DIR}/rabbitmq.pid"
export RABBITMQ_USE_LONGNAME="true"
export RABBITMQ_VHOST="<%= p('rabbitmq.vhost') %>"
export RABBITMQ_EVAL_TIMEOUT="90"

# Erlang
export EPMD_PID_FILE="${RUN_DIR}/epmd.pid"
export ERL_INETRC=${JOB_DIR}/config/erl_inetrc

# Elixir expects utf8, locale must be set to UTF-8.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Erlang & RabbitMQ Binaries
export PATH=$PATH:/var/vcap/packages/erlang/bin:/var/vcap/packages/rabbitmq/sbin

