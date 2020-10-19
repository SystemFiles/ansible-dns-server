#!/bin/bash
# Run test on docker container

echo "---- [ Starting test ] ----"
ansible-playbook ./ansible-plays/install_configure_play.yml

# Test commands to verify resolution is working
dig webserver.sykeshome @127.0.0.1
dig google.com @127.0.0.1

# Check test status
if [[ $? -ne 0 ]]; then
    # Fail
    echo "TEST FAILED... see output for more details."
    exit 1
fi

echo "TEST SUCCESS!"
exit 0