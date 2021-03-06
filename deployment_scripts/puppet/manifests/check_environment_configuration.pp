#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# This manifest is only executed on the primrary-controller to verify that the
# plugin's configuration matches with the environment.

$lma_collector = hiera_hash('lma_collector')

$elasticsearch_mode = $lma_collector['elasticsearch_mode']
if $elasticsearch_mode == 'local' {
  # Check that the Elasticsearch-Kibana plugin is enabled for that environment
  # and that the node names match
  $elasticsearch_kibana = hiera_hash('elasticsearch_kibana', false)
  if ! $elasticsearch_kibana {
    fail('Could not get the Elasticsearch parameters. The Elasticsearch-Kibana plugin is probably not installed.')
  }
  elsif ! $elasticsearch_kibana['metadata']['enabled'] {
    fail('Could not get the Elasticsearch parameters. The Elasticsearch-Kibana plugin is probably not enabled for this environment.')
  }

  # Check that the Elasticsearch-Kibana node exists in the environment
  $es_nodes = filter_nodes(hiera('nodes'), 'role', 'elasticsearch_kibana')
  if size($es_nodes) < 1 {
    fail("Could not find node with role 'elasticsearch_kibana' in the environment")
  }
}

$influxdb_mode = $lma_collector['influxdb_mode']
if $influxdb_mode == 'local' {
  # Check that the InfluxDB-Grafana plugin is enabled for that environment
  # and that the node names match
  $influxdb_grafana = hiera_hash('influxdb_grafana', false)
  if ! $influxdb_grafana {
    fail('Could not get the InfluxDB parameters. The InfluxDB-Grafana plugin is probably not installed.')
  }
  elsif ! $influxdb_grafana['metadata']['enabled'] {
    fail('Could not get the InfluxDB parameters. The InfluxDB-Grafana plugin is probably not enabled for this environment.')
  }
  # Check that the InfluxDB-Grafana node exists in the environment
  $influxdb_nodes = filter_nodes(hiera('nodes'), 'role', 'influxdb_grafana')
  if size($influxdb_nodes) < 1 {
    fail("Could not find node with role 'influxdb_grafana' in the environment")
  }
}

$alerting_mode = $lma_collector['alerting_mode']
if $alerting_mode == 'local' {
  # Check that the LMA-Infrastructure-Alerting plugin is enabled for that environment
  # and that the node names match
  $infra_alerting = hiera_hash('lma_infrastructure_alerting', false)
  if ! $infra_alerting {
    fail('Could not get the LMA Infrastructure Alerting parameters. The LMA-Infrastructure-Alerting plugin is probably not installed.')
  }
  elsif ! $infra_alerting['metadata']['enabled'] {
    fail('Could not get the LMA Infrastructure Alerting parameters. The LMA-Infrastructure-Alerting plugin is probably not enabled for this environment.')
  }
  # Check that the LMA-Infrastructure-Alerting node exists in the environment
  $infra_alerting_nodes = filter_nodes(hiera('nodes'), 'role', 'infrastructure_alerting')
  if size($infra_alerting_nodes) < 1 {
    fail("Could not find node with role 'infrastructure_alerting' in the environment")
  }
}
