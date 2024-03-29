#!/usr/bin/env bash
set -x
env

COMMAND_STANDALONE="standalone-job"
# Deprecated, should be remove in Flink release 1.13
COMMAND_NATIVE_KUBERNETES="native-k8s"
COMMAND_HISTORY_SERVER="history-server"

# If unspecified, the hostname of the container is taken as the JobManager address
JOB_MANAGER_RPC_ADDRESS=${JOB_MANAGER_RPC_ADDRESS:-$(hostname -f)}
CONF_FILE="${FLINK_HOME}/conf/flink-conf.yaml"

drop_privs_cmd() {
    if [ $(id -u) != 0 ]; then
        # Don't need to drop privs if EUID != 0
        return
    elif [ -x /sbin/su-exec ]; then
        # Alpine
        echo su-exec flink
    else
        # Others
        echo gosu flink
    fi
}

copy_plugins_if_required() {
    if [ -z "$ENABLE_BUILT_IN_PLUGINS" ]; then
        return 0
    fi

    echo "Enabling required built-in plugins"
    for target_plugin in $(echo "$ENABLE_BUILT_IN_PLUGINS" | tr ';' ' '); do
        echo "Linking ${target_plugin} to plugin directory"
        plugin_name=${target_plugin%.jar}

        mkdir -p "${FLINK_HOME}/plugins/${plugin_name}"
        if [ ! -e "${FLINK_HOME}/opt/${target_plugin}" ]; then
            echo "Plugin ${target_plugin} does not exist. Exiting."
            exit 1
        else
            ln -fs "${FLINK_HOME}/opt/${target_plugin}" "${FLINK_HOME}/plugins/${plugin_name}"
            echo "Successfully enabled ${target_plugin}"
        fi
    done
}

set_config_option() {
    local option=$1
    local value=$2

    # escape periods for usage in regular expressions
    local escaped_option=$(echo ${option} | sed -e "s/\./\\\./g")

    # either override an existing entry, or append a new one
    if grep -E "^${escaped_option}:.*" "${CONF_FILE}" >/dev/null; then
        sed -i -e "s/${escaped_option}:.*/$option: $value/g" "${CONF_FILE}"
    else
        echo "${option}: ${value}" >>"${CONF_FILE}"
    fi
}

prepare_configuration() {
    set_config_option jobmanager.rpc.address ${JOB_MANAGER_RPC_ADDRESS}
    set_config_option blob.server.port 6124
    set_config_option query.server.port 6125

    TASK_MANAGER_NUMBER_OF_TASK_SLOTS=${TASK_MANAGER_NUMBER_OF_TASK_SLOTS:-1}
    set_config_option taskmanager.numberOfTaskSlots ${TASK_MANAGER_NUMBER_OF_TASK_SLOTS}

    if [ -n "${FLINK_PROPERTIES}" ]; then
        echo "${FLINK_PROPERTIES}" >>"${CONF_FILE}"
    fi
    envsubst <"${CONF_FILE}" >"${CONF_FILE}.tmp" && mv "${CONF_FILE}.tmp" "${CONF_FILE}"
}

maybe_enable_jemalloc() {
    if [ "${DISABLE_JEMALLOC:-false}" == "false" ]; then
        export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libjemalloc.so
    fi
}

set_host_aliases() {
    if [[ $KUBERNETES_HOST_ALIASES != "" ]]; then
        host_msg="\n----------set host-----------\n $KUBERNETES_HOST_ALIASES \n"
        echo -e $host_msg
        KUBERNETES_HOST_ALIASES=${KUBERNETES_HOST_ALIASES//;/\\n}
        echo -e "$KUBERNETES_HOST_ALIASES" >>/etc/hosts
        cat /etc/hosts
    fi
}

set_main_jar() {
    if [[ "$KUBERNETES_REMOTE_MAIN_JAR" != "" ]]; then
        host_msg="\n----------download remote main jar-----------\n $KUBERNETES_REMOTE_MAIN_JAR \n"
        echo -e $host_msg
        python3 /minio_client.py --src=${KUBERNETES_REMOTE_MAIN_JAR} --dest=${KUBERNETES_LOCAL_MAIN_JAR}
        echo "downloaded main jar-----------\n $KUBERNETES_LOCAL_MAIN_JAR \n"
        du -hl ${KUBERNETES_LOCAL_MAIN_JAR}
    fi
}

set_flinkx_classpath() {
    # flinkx classpath:flinkx-core
    plugin_jars=$(find $FLINKX_HOME -maxdepth 1 -type f -name "flinkx-*.jar")
    FLINKX_CLASSPATH=${plugin_jars//[[:space:]]/\:}
}

set_hadoop_classpath() {
    # if plugin is hdfs or hive
    if [[ ${FLINKX_SOURCE_PLUGIN} == "hdfs" || ${FLINKX_SOURCE_PLUGIN} != "hive" || ${FLINKX_SINK_PLUGIN} == "hdfs" || ${FLINKX_SINK_PLUGIN} != "hive" ]]; then
        export HADOOP_CLASSPATH="$(${CDH_HOME}/lib/hadoop/bin/hadoop classpath)"
    fi
}

maybe_enable_jemalloc

copy_plugins_if_required

prepare_configuration

set_host_aliases

set_main_jar

set_flinkx_classpath

args=("$@")
if [ "$1" = "help" ]; then
    printf "Usage: $(basename "$0") (jobmanager|${COMMAND_STANDALONE}|taskmanager|${COMMAND_HISTORY_SERVER})\n"
    printf "    Or $(basename "$0") help\n\n"
    printf "By default, Flink image adopts jemalloc as default memory allocator. This behavior can be disabled by setting the 'DISABLE_JEMALLOC' environment variable to 'true'.\n"
    exit 0
elif [ "$1" = "jobmanager" ]; then
    args=("${args[@]:1}")

    echo "Starting Job Manager"

    exec $(drop_privs_cmd) "$FLINK_HOME/bin/jobmanager.sh" start-foreground "${args[@]}"
elif [ "$1" = ${COMMAND_STANDALONE} ]; then
    args=("${args[@]:1}")

    echo "Starting Job Manager"

    exec $(drop_privs_cmd) "$FLINK_HOME/bin/standalone-job.sh" start-foreground "${args[@]}"
elif [ "$1" = ${COMMAND_HISTORY_SERVER} ]; then
    args=("${args[@]:1}")

    echo "Starting History Server"

    exec $(drop_privs_cmd) "$FLINK_HOME/bin/historyserver.sh" start-foreground "${args[@]}"
elif [ "$1" = "taskmanager" ]; then
    args=("${args[@]:1}")

    echo "Starting Task Manager"

    exec $(drop_privs_cmd) "$FLINK_HOME/bin/taskmanager.sh" start-foreground "${args[@]}"
elif [ "$1" = "$COMMAND_NATIVE_KUBERNETES" ]; then
    args=("${args[@]:1}")

    set_hadoop_classpath
    export _FLINK_HOME_DETERMINED=true
    . $FLINK_HOME/bin/config.sh
    export FLINK_CLASSPATH="$FLINKX_CLASSPATH:$(constructFlinkClassPath):$INTERNAL_HADOOP_CLASSPATHS"
    # Start commands for jobmanager and taskmanager are generated by Flink internally.
    echo "Start command: ${args[@]}"
    exec $(drop_privs_cmd) bash -c "${args[@]}"
fi

args=("${args[@]}")

# Set the Flink related environments
export _FLINK_HOME_DETERMINED=true
. $FLINK_HOME/bin/config.sh
export FLINK_CLASSPATH="$FLINKX_CLASSPATH:$(constructFlinkClassPath):$INTERNAL_HADOOP_CLASSPATHS"

# Running command in pass-through mode
exec $(drop_privs_cmd) "${args[@]}"
