#!/bin/bash
if [ "$1" = "--list" ]; then
	cat ../terraform/modules/outs_for_ansible/outs.json
elif [ "$1" = "--host" ]; then
	echo '{"_meta": {"hostvars": {}}}'
fi

