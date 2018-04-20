export NODE_IP=`hostname -I`
export CASSANDRA_YML="/etc/cassandra/cassandra.yaml"
export CLUSTER_NAME="devoops_cluster"

name_list=""
while read name
do
  if [ -z $name_list ]; then
      name_list="$name"
   else
      name_list="$name_list,$name"
      SEEDS=$name_list
   fi
done < /tmp/ips.txt

sed -i 's/- seeds: "127.0.0.1"/- seeds: '\"$SEEDS\"'/g' ${CASSANDRA_YML}
sed -i "/cluster_name:/c\cluster_name: \'${CLUSTER_NAME}\'"  ${CASSANDRA_YML}
sed -i "/listen_address:/c\listen_address: ${NODE_IP}"       ${CASSANDRA_YML}
sed -i "/rpc_address:/c\rpc_address: ${NODE_IP}"             ${CASSANDRA_YML}
