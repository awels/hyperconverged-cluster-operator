#!/bin/bash -x
#
# This file is part of the KubeVirt project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright 2021 Red Hat, Inc.
#
# This script checks the defaulting mechanism

echo "Read the CR's spec before starting the test"
${KUBECTL_BINARY} get hco -n "${INSTALLED_NAMESPACE}" kubevirt-hyperconverged -o json | jq '.spec'

CERTCONFIGDEFAULTS='{"ca":{"duration":"48h0m0s","renewBefore":"24h0m0s"},"server":{"duration":"24h0m0s","renewBefore":"12h0m0s"}}'
FGDEFAULTS='{"enableCommonBootImageImport":false,"sriovLiveMigration":true,"withHostPassthroughCPU":false}'
LMDEFAULTS='{"completionTimeoutPerGiB":800,"parallelMigrationsPerCluster":5,"parallelOutboundMigrationsPerNode":2,"progressTimeout":150}'
PERMITTED_HOST_DEVICES_DEFAULT1='{"pciDeviceSelector":"10DE:1DB6","resourceName":"nvidia.com/GV100GL_Tesla_V100"}'
PERMITTED_HOST_DEVICES_DEFAULT2='{"pciDeviceSelector":"10DE:1EB8","resourceName":"nvidia.com/TU104GL_Tesla_T4"}'

CERTCONFIGPATHS=(
    "/spec/certConfig/ca/duration"
    "/spec/certConfig/ca/renewBefore"
    "/spec/certConfig/ca"
    "/spec/certConfig/server/duration"
    "/spec/certConfig/server/renewBefore"
    "/spec/certConfig/server"
    "/spec/certConfig"
    "/spec"
)

FGPATHS=(
    "/spec/featureGates/enableCommonBootImageImport"
    "/spec/featureGates/withHostPassthroughCPU"
    "/spec/featureGates/sriovLiveMigration"
    "/spec/featureGates"
    "/spec"
)

LMPATHS=(
    "/spec/liveMigrationConfig/parallelMigrationsPerCluster"
    "/spec/liveMigrationConfig/parallelOutboundMigrationsPerNode"
    "/spec/liveMigrationConfig/bandwidthPerMigration"
    "/spec/liveMigrationConfig/completionTimeoutPerGiB"
    "/spec/liveMigrationConfig/progressTimeout"
    "/spec/liveMigrationConfig"
    "/spec"
)

echo "Check that certConfig defaults are behaving as expected"

./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type=json kubevirt-hyperconverged -p '[{ \"op\": \"replace\", \"path\": /spec, \"value\": {} }]'"
for JPATH in "${CERTCONFIGPATHS[@]}"; do
    ./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type='json' kubevirt-hyperconverged -p '[{ \"op\": \"remove\", \"path\": '\"${JPATH}\"' }]'"
    CERTCONFIG=$(${KUBECTL_BINARY} get hco -n "${INSTALLED_NAMESPACE}" kubevirt-hyperconverged -o jsonpath='{.spec.certConfig}')
    if [[ "${CERTCONFIGDEFAULTS}" != "${CERTCONFIG}" ]]; then
        echo "Failed checking CR defaults for certConfig"
        exit 1
    fi
    sleep 2
done

echo "Check that featureGates defaults are behaving as expected"

./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type=json kubevirt-hyperconverged -p '[{ \"op\": \"replace\", \"path\": /spec, \"value\": {} }]'"
for JPATH in "${FGPATHS[@]}"; do
    ./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type='json' kubevirt-hyperconverged -p '[{ \"op\": \"remove\", \"path\": '\"${JPATH}\"' }]'"
    FG=$(${KUBECTL_BINARY} get hco -n "${INSTALLED_NAMESPACE}" kubevirt-hyperconverged -o jsonpath='{.spec.featureGates}')
    if [[ $FGDEFAULTS != $FG ]]; then
        echo "Failed checking CR defaults for featureGates"
        exit 1
    fi
    sleep 2
done

echo "Check that featureGates defaults are behaving as expected"

./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type=json kubevirt-hyperconverged -p '[{ \"op\": \"replace\", \"path\": /spec, \"value\": {} }]'"
for JPATH in "${LMPATHS[@]}"; do
    ./hack/retry.sh 10 3 "${KUBECTL_BINARY} patch hco -n \"${INSTALLED_NAMESPACE}\" --type='json' kubevirt-hyperconverged -p '[{ \"op\": \"remove\", \"path\": '\"${JPATH}\"' }]'"
    LM=$(${KUBECTL_BINARY} get hco -n "${INSTALLED_NAMESPACE}" kubevirt-hyperconverged -o jsonpath='{.spec.liveMigrationConfig}')
    if [[ $LMDEFAULTS != $LM ]]; then
        echo "Failed checking CR defaults for liveMigrationConfig"
        exit 1
    fi
    sleep 2
done
