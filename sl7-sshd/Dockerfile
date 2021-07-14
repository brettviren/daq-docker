### WARNING: read comments thoroughly.
#
# This Dockerfile can be used add sshd entry point.
#
# This is perhaps not good to put on docker-hub as it requires each
# user to do something:
#
# 1) In this directory run:
#
#   ssh-keygen -f id_user -C "user@dunedaq"
#
# Both public and private keys are added to the container.  This is
# not necessarily very secure.
#
# 2) Change the UID in useradd line to match your normal use on your
# host if you want to be able to write to your native $HOME in the
# container.
#
# 3) Run
#
#   docker build -t dunedaq/sl7-sshd .
#
# 4) Run something like:
#
#   docker run \
#     -v /cvmfs:/cvmfs:shared \
#     --mount type=bind,source=${HOME},target=${HOME} \
#     -p 127.0.0.1:2222:22/tcp -ti dunedaq/sl7-sshd
#
# 5) In the container run sshd.  I don't know why if fails to start as
# part of the RUN...
#
#  [root@1b23f5e066c5 /]# /usr/sbin/sshd
#  [root@1b23f5e066c5 /]# 
#
# 6) Log in as desired
#
#  $ ssh user@localhost -p 2222
#
# 7) To shutdown, log out all "user" and in the root image session
#
#  [root@1b23f5e066c5 /]# killall sshd
#  [root@1b23f5e066c5 /]# exit
#
# FIN.


FROM dunedaq/sl7:latest

MAINTAINER Brett Viren "bv@bnl.gov"
ENV REFRESHED_AT 2021-05-28

RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN ssh-keygen -A
RUN mkdir -p /root/.ssh/ && chmod 700 /root/.ssh
COPY id_user.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

## best to make the UID match if you want to bind-mount $HOME and be
## able to write.
RUN useradd -u 1001 -d /home/user -ms /bin/bash user
RUN mkdir -p /home/user/.ssh/ && chmod 700 /home/user/.ssh
COPY id_user.pub /home/user/.ssh/id_rsa.pub
RUN chmod 400 /home/user/.ssh/id_rsa.pub
COPY id_user.pub /home/user/.ssh/authorized_keys
RUN chmod 600 /home/user/.ssh/authorized_keys
COPY id_user /home/user/.ssh/id_rsa
RUN chmod 400 /home/user/.ssh/id_rsa
RUN chown -R user:user /home/user/.ssh
ENTRYPOINT ["/bin/bash"]




