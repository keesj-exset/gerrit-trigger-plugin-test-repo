Gerrit and Jenkins setup
************************

We are performing a setup with gerrit and jenkins using docker

Docker install
==============

We use *docker-ce-cli* as package


.. code-block:: sh

    apt-get install docker-ce-cli


create env.sh

.. code-block:: sh

    export IP=10.0.3.1

Run gerrit in persistance mode

.. code-block:: sh

    . env.sh
    docker run -it --rm -p $IP:8080:8080 -p $IP:29418:29418  \
        -v gerrit-a:/var/gerrit/etc \
        -v gerrit-b:/var/gerrit/git \
        -v gerrit-c:/var/gerrit/db \
        -v gerrit-d:/var/gerrit/index \
        -v gerrit:/var/gerrit/cache \
        -e CANONICAL_WEB_URL=http://$IP:8080/ \
        gerritcodereview/gerrit


Run jenkins with persistance

.. code-block:: sh

    . env.sh
    docker run -it --rm -p $IP:8090:8080 -v jenkins_home:/var/jenkins_home jenkins/jenkins


Configure gerrit. 
=================

By default gerrit no longer has the verified label hence we need to modify the configuration.

go to http://10.0.3.1:8080/


>> skip intro
>> Admin settings ssh key (upload key)

.. code-block:: sh

    cat .ssh/id_rsa.pub | xclip -selection clipboard


Clone the All-project to add the verified label

.. code-block:: sh

        git clone "ssh://admin@10.0.3.1:29418/All-Projects"
        cd All-Projects
        git fetch origin refs/meta/config:refs/remotes/origin/meta/config
        git config user.name "admin"
        git config user.email "admin@example.com"

Edit project.config to add the Verified block at the end

.. code-block:: sh

    [label "Verified"]
        function = MaxWithBlock
        value = -1 Fails
        value =  0 No score
        value = +1 Verified

Push back the changes

.. code-block:: sh

    git add project.config
    git commit -m "Adding a verified label"
    git push origin HEAD:meta/config

Create a jenkins user on the gerrit server

.. code-block:: sh

    . env.sh
    ssh -p 29418 admin@$IP gerrit create-account jenkins


Create an ssh key for the jenkins user on the jenkins server

.. code-block:: sh

        . env.sh
        ID=`docker ps | grep jen | sed "s,.* ,,g"`
        docker exec -it $ID bash
        cd
        ssh-keygen

An upload the ssh key to gerrit to allow jenkins to perform operations on gerrit (label verified)

.. code-block:: sh

        . env.sh
        ID=`docker ps | grep jen | sed "s,.* ,,g"`
        docker cp $ID:/var/jenkins_home/.ssh/id_rsa.pub .
        cat id_rsa.pub | ssh -p 29418 admin@$IP gerrit set-account --add-ssh-key - jenkins

Allow to connect between jenkins and gerrit

.. code-block:: sh

    ufw allow from 172.17.0.3/24 to 10.0.3.1/24


Add jenkins to the non interactive users

.. code-block:: sh

        . env.sh
        ssh -p 29418 admin@10.0.3.1 gerrit set-members "Non-Interactive\ Users" --add jenkins


Try connecting to gerrit from the jenkins user

.. code-block:: sh

        . env.sh
        ID=`docker ps | grep jen | sed "s,.* ,,g"`
        docker exec -it $ID ssh -p 29418 jenkins@$IP gerrit ls-projects


Following the `Gerrit trigger official documentation <https://plugins.jenkins.io/gerrit-trigger/>`_

.. code-block:: sh

        Admin > Projects > Browse > Repositories > All-Projects > Access > Edit
            Reference: refs/*
                Read: ALLOW for Non-Interactive Users
            Reference: refs/heads/*
                Label Code-Review: -1, +1 for Non-Interactive Users
                Label Verified: -1, +1 for Non-Interactive Users


Create a gerrit_test project 

.. code-block:: sh

        . env.sh
        ssh -p 29418 admin@10.0.3.1 gerrit create-project gerrit_test


Upload the test repo

.. code-block:: sh

        git clone https://github.com/keesj-exset/gerrit-trigger-plugin-test-repo.git gerrit_test
        . env.sh
        cd gerrit_test
        git remote rm origin
        git remote add origin ssh://admin@$IP:29418/gerrit_test
        git push origin master

        # add the gerrit commit hook (to add commit-id to commits)
        gitdir=$(git rev-parse --git-dir); scp -p -P 29418 admin@$IP:hooks/commit-msg ${gitdir}/hooks/


Setup jenkins

open to http://10.0.3.1:8090/

.. code-block:: sh

        . env.sh
        ID=`docker ps | grep jen | sed "s,.* ,,g"`
        docker exec -it $ID cat /var/jenkins_home/secrets/initialAdminPassword | xclip -selection clipboard

Login 

Select install suggested plugins
create the admin account

user
    admin
passwd
    admin2k


Install the gerrit-trigger plugin

Configure the plugin by adding a server (select the few options to enable the abort functionality

.. image:: img/configure_plugin.png


.. code-block:: 

    * Create a new job.
     * New Item  
      * (Name gerrit_test_builder)
      *   Freestyle project
     * Source code management 
      * git
      * repository URL ssh://jenkins@10.0.3.1:29418/gerrit_test
        * Advanced Refspec  $GERRIT_REFSPEC  (also documented here https://plugins.jenkins.io/gerrit-trigger/ )
      * Additional behaviours " Strategy for choosing what to build " -> Gerrit Trigger
      * Add "Change merged" as event (also documented here https://plugins.jenkins.io/gerrit-trigger/ )
    * Build Triggers
      * gerrit event
      * Select "gerrit" as server 
      * In gerrit project select gerrit_test
      * In pattern enter "path" **
    * Build
      * Add additional steps
      * execute shell script
      * ./build.sh.

Test by running build now

Testing:

cd gerrit_test
run ./update.sh . this should trigger jenkins  let it run and look into gerrit that the build was verified (+1)

run ./update.sh again but now wait for 15 seconds and then run ./rework.sh 

The expected result is that the job shows that the build was aborted but the the build verified is not set to -1.


.. image:: img/expected.png
    

